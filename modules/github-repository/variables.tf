variable "organization_name" {
  type        = string
  description = "The name of the GitHub organization in which to create the resources."
  nullable    = false

  validation {
    error_message = "Organization name must be at least 1 character long."
    condition     = length(var.organization_name) > 0
  }

  validation {
    error_message = "Organization name must not be a URL."
    condition     = !can(regex("https?://", var.organization_name))
  }

  validation {
    error_message = "Organization name must not contain `github.com`."
    condition     = !strcontains(var.organization_name, "github.com")
  }
}

variable "repository_name" {
  type        = string
  description = "The name of the GitHub repository to create."
  nullable    = false
}

variable "repository_visibility" {
  type        = string
  description = "The visibility of the repository. Must be one of: `public`, or `private`."
  default     = "private"
  nullable    = false

  validation {
    error_message = "Visibility must be one of: `public`, or `private`."
    condition     = contains(["public", "private"], var.repository_visibility)
  }
}

variable "team_name" {
  type        = string
  description = "The name of the GitHub team to create. Team will not be created is there are no approvers."
  nullable    = false
}

variable "access_level" {
  type        = string
  default     = "organization"
  description = "The access level for the repository (only pertains to private repos). Must be one of: `none`, `user`, `organization`, or `enterprise`."
  nullable    = false

  validation {
    error_message = "Access level must be one of: `none`, `user`, `organization`, or `enterprise`."
    condition     = contains(["none", "user", "organization", "enterprise"], var.access_level)
  }
}

variable "approvers" {
  type        = list(string)
  default     = []
  description = "The list of GitHub user e-mail addresses that are allowed to approve pull requests."
  nullable    = false

  validation {
    error_message = "The list of approvers must be unique."
    condition     = length(var.approvers) == length(distinct(var.approvers))
  }
}

variable "codeowners_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create a `.github/CODEOWNERS` file containing the created team."
  nullable    = false

  validation {
    error_message = "Codeowners requires approvers."
    condition     = !var.codeowners_enabled ? true : length(var.approvers) > 0
  }
}

variable "environments" {
  type = map(object({
    name                    = string
    review_required         = optional(bool, false)
    protected_branches_only = optional(bool, false)
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
A map of environments to create in the repository.
The map key is arbitrary and the value is an object with the following attributes:

- `name`: (Required) The name of the environment.
- `review_required`: (Optional) Whether or not a review is required to deploy to the environment. Requires approvers. Default is `true`.
- `protected_branches_only`: (Optional) Whether or not the environment is only available on protected branches. Default is `false`.

See `var.environment_secrets`, `var.environment_secrets_values`, and `var.environments_variables` for environment specific configuration.
DESCRIPTION
}

variable "environments_secrets" {
  type        = map(set(string))
  default     = {}
  description = <<DESCRIPTION
The map of environments to secret names.
The map key is the environment name and the value is a set of secret names.
The secret value is stored in `var.environments_secrets_values` as it is sensitive and cannot be used in a `for_each` map key.
DESCRIPTION
  nullable    = false
}

variable "environments_secrets_values" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
The map of environment secrets and their values.
This must be stored in a seperate variable as it is sensitive and cannot be used in a `for_each` map key.
The map key is a composite of the environment name and the secret name, separated by a slash.

Example:

Environment name: `prod`
Secret name: `db_password`

```hcl
environments_secrets_values = {
  "prod/db_password": "SECRET VALUE"
}
```
DESCRIPTION
  nullable    = false
  sensitive   = true
}

variable "environments_variables" {
  type = map(object({
    variables = map(string)
  }))
  default  = {}
  nullable = false
}

variable "files" {
  type = map(object({
    content = string
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
A map of files to create in the repository.
The map key is the file path and the value is the file content.
DESCRIPTION
}

variable "repository_description" {
  type        = string
  default     = null
  description = "The description of the GitHub repository to create."
}

variable "oidc_subject_claim_keys" {
  type        = set(string)
  default     = []
  description = "The set of claim keys to use as the subject in the OIDC token. An empty set will use the default claim key."
  nullable    = false
}

variable "approving_review_count" {
  type        = number
  default     = 0
  description = "The number of approving reviews required for a pull request."
  nullable    = false

  validation {
    error_message = "Value must be a zero or a positive integer."
    condition     = abs(floor(var.approving_review_count)) == var.approving_review_count
  }
  validation {
    error_message = "Value must be greater than or equal to `0` and less than `11`."
    condition     = var.approving_review_count >= 0 && var.approving_review_count < 11
  }
  validation {
    error_message = "Must be less than or equal to `length(var.github_approvers)`."
    condition     = var.approving_review_count <= length(var.approvers)
  }
}

variable "ruleset_bypass" {
  type = list(object({
    actor_id    = optional(number, null)
    actor_type  = string
    role_name   = optional(string, null)
    bypass_mode = string
  }))
  default     = []
  description = <<DESCRIPTION
The list of GitHub usernames that are allowed to bypass the repository ruleset.

- `actor_type`: (Required) Must be one of: `RepositoryRole`, `Team`, `Integration`, or `OrganizationAdmin`.
- `actor_id`: (Optional) The ID of the actor, this must be supplied when `actor_type` is `Team` or `Integration`.
- `bypass_mode`: (Required) Must be one of: `always`, or `pull_request`.
- `role_name`: (Optional) The role of the actor, this must be supplied when `actor_type` is `RepositoryRole`. Possible values are:
  - `admin`
  - `write`
  - `maintain`

DESCRIPTION
  nullable    = false

  validation {
    error_message = "`actor_type` must be one of: `RepositoryRole`, `Team`, `Integration`, or `OrganizationAdmin`."
    condition     = length(var.ruleset_bypass) == 0 ? true : alltrue([for bypass in var.ruleset_bypass : contains(["RepositoryRole", "Team", "Integration", "OrganizationAdmin"], bypass.actor_type)])
  }
  validation {
    error_message = "`bypass_mode` must be one of: `always`, or `pull_request`."
    condition     = length(var.ruleset_bypass) == 0 ? true : alltrue([for bypass in var.ruleset_bypass : contains(["always", "pull_request"], bypass.bypass_mode)])
  }
  validation {
    error_message = "When `actor_type` is `Team` or `Integration`, `actor_id` must be supplied."
    condition     = alltrue([for bypass in var.ruleset_bypass : !contains(["Team", "Integration"], bypass.actor_type) ? true : bypass.actor_id != null])
  }
  validation {
    error_message = "When `actor_type` is `RepositoryRole`, `role_name` must be one of `maintain`, `write`, `admin`."
    condition     = alltrue([for bypass in var.ruleset_bypass : try(contains(["maintain", "write", "admin"], bypass.role_name), false) if bypass.actor_type == "RepositoryRole"])
  }
  validation {
    error_message = "When `actor type` is not `RepositoryRole`, `role_name` must be `null`."
    condition     = alltrue([for bypass in var.ruleset_bypass : bypass.role_name == null if bypass.actor_type != "RepositoryRole"])
  }
}

variable "ruleset_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to create the GitHub repository ruleset (branch protection). Requires a public repo, or a pro or Enterprise plan."
  nullable    = false
}

variable "ruleset_name" {
  type        = string
  default     = "main ruleset"
  description = "The name of the GitHub repository ruleset."
  nullable    = false
}

variable "runner_group_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to use a runner group. Requires an enterprise plan."
  nullable    = false
}

variable "runner_group_name" {
  type        = string
  default     = null
  description = "The name of the runner group to create."

  validation {
    condition     = !var.runner_group_enabled ? true : var.runner_group_name != null
    error_message = "A runner group name must be provided when `runner_group_enabled` is `true`."
  }
}

variable "status_checks" {
  type = set(object({
    context        = string
    integration_id = optional(number, null)
  }))
  default     = []
  description = <<DESCRIPTION
The list of status checks to require before merging a pull request:

- `context`: (Required) The name of the status check.
- `integration_id`: (Optional) The ID of the GitHub App integration that provides the status check.
DESCRIPTION
  nullable    = false
}

variable "status_checks_strict_policy_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to enforce a strict required status checks policy."
  nullable    = false
}

variable "team_description" {
  type        = string
  default     = null
  description = "The description of the GitHub team to create."
}

variable "team_role" {
  type        = string
  default     = "push"
  description = "The role to assign to the team. Suitable built-in roles are: `push`, `maintain`, and `admin`."
  nullable    = false
}

variable "workflows" {
  type = map(object({
    workflow_file_name = string
    environment_user_assigned_managed_identity_mappings = list(object({
      environment_key                    = string
      user_assigned_managed_identity_key = string
    }))
  }))
  default     = {}
  nullable    = false
  description = <<DESCRIPTION
The map of workflows in the repository. This information is used to generate the OIDC subject claim.
The map key is the workflow name and the value is a list of environment user assigned managed identity mappings.
The User Assigned Managed Identity Key is used to identify the Azure resource that the workflow should be associated with.
DESCRIPTION

  validation {
    error_message = "The workflow file must exist in `var.files`."
    condition     = alltrue([for _, value in var.workflows : contains(keys(var.files), value.workflow_file_name)])
  }
}

variable "branch_protection_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to create branch protection rules for the repository. Note we recommend rulesets are used instead - rulesets require a paid plan or a public repo."
  nullable    = false
}

variable "branch_protection_bypass_actors" {
  type        = set(string)
  default     = []
  nullable    = false
  description = <<DESCRIPTION
The list of actor Names/IDs that are allowed to bypass pull request requirements. Actor names must either begin with a '/' for users or the organization name followed by a '/' for teams.
DESCRIPTION

  validation {
    error_message = "Actor names must either begin with a '/' for users or the organization name followed by a '/' for teams."
    condition     = alltrue([for actor in var.branch_protection_bypass_actors : can(regex("^(?:/|${var.organization_name}/).+$", actor))])
  }
}
