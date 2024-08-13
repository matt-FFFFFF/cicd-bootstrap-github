variable "github_organization_name" {
  description = "The name of the GitHub organization in which to create the resources."
  type        = string
  nullable    = false
}

variable "github_repository_ruleset_enabled" {
  type        = bool
  default     = true
  nullable    = false
  description = "Whether or not to create the GitHub repository ruleset (branch protection)."
}

variable "github_repository_name" {
  description = "The name of the GitHub repository to create."
  type        = string
  nullable    = false
}

variable "github_repository_ruleset_approving_review_count" {
  type        = number
  default     = 0
  nullable    = false
  description = "The number of approving reviews required for a pull request."

  validation {
    error_message = "Value must be a zero or a positive integer."
    condition     = abs(floor(var.github_repository_ruleset_approving_review_count)) == var.github_repository_ruleset_approving_review_count
  }

  validation {
    error_message = "Value must be greater than or equal to `0` and less than `11`."
    condition     = var.github_repository_ruleset_approving_review_count >= 0 && var.github_repository_ruleset_approving_review_count < 11
  }

  validation {
    error_message = "Must be less than or equal to `length(var.github_approvers)`."
    condition     = var.github_repository_ruleset_approving_review_count <= length(var.github_approvers)
  }
}

variable "github_repository_description" {
  type        = string
  description = "The description of the GitHub repository to create."
  default     = null
}

variable "github_approvers" {
  type        = list(string)
  description = "The list of GitHub usernames that are allowed to approve pull requests."
  default     = []
  nullable    = false
}

variable "github_respository_ruleset_bypass" {
  type = list(object({
    actor_id    = optional(number, null)
    actor_type  = string
    role_name   = optional(string, null)
    bypass_mode = string
  }))
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
  default     = []
  nullable    = false

  validation {
    error_message = "`actor_type` must be one of: `RepositoryRole`, `Team`, `Integration`, or `OrganizationAdmin`."
    condition     = length(var.github_respository_ruleset_bypass) == 0 ? true : alltrue([for bypass in var.github_respository_ruleset_bypass : contains(["RepositoryRole", "Team", "Integration", "OrganizationAdmin"], bypass.actor_type)])
  }

  validation {
    error_message = "`bypass_mode` must be one of: `always`, or `pull_request`."
    condition     = length(var.github_respository_ruleset_bypass) == 0 ? true : alltrue([for bypass in var.github_respository_ruleset_bypass : contains(["always", "pull_request"], bypass.bypass_mode)])
  }

  validation {
    error_message = "When `actor_type` is `Team` or `Integration`, `actor_id` must be supplied."
    condition     = alltrue([for bypass in var.github_respository_ruleset_bypass : !contains(["Team", "Integration"], bypass.actor_type) ? true : bypass.actor_id != null])
  }

  validation {
    error_message = "When `actor_type` is `RepositoryRole`, `role_name` must be one of `maintain`, `write`, `admin`."
    condition     = alltrue([for bypass in var.github_respository_ruleset_bypass : try(contains(["maintain", "write", "admin"], bypass.role_name), false) if bypass.actor_type == "RepositoryRole"])
  }

  validation {
    error_message = "When `actor type` is not `RepositoryRole`, `role_name` must be `null`."
    condition     = alltrue([for bypass in var.github_respository_ruleset_bypass : bypass.role_name == null if bypass.actor_type != "RepositoryRole"])
  }
}

variable "github_repository_ruleset_name" {
  type        = string
  description = "The name of the GitHub repository ruleset."
  default     = "main ruleset"
  nullable    = false
}
