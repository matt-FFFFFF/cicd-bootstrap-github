locals {
  approvers            = [for user in data.github_organization.this.users : user.login if contains(var.approvers, user.email)]
  default_commit_email = coalesce(local.primary_approver, "demo@microsoft.com")
  environments_secrets = { for item in flatten([
    for env, names in var.environments_secrets : [
      for sec_name in names : {
        environment = env
        key         = sec_name
      }
    ]
    ]) : "${item.environment}/${item.key}" => {
    environment = item.environment
    key         = item.key
    }
  }
  environments_variables = { for item in flatten([
    for env, value in var.environments_variables : [
      for env_name, env_value in value.variables : {
        environment = env
        key         = env_name
        env_value   = env_value
      }
    ]
    ]) : "${item.environment}/${item.env_name}" => {
    value       = item.env_value
    environment = item.environment
    key         = item.key
    }
  }
  oidc_subjects = { for oidc_subject in local.oidc_subjects_flattened : oidc_subject.subject_key => {
    user_assigned_managed_identity_key = oidc_subject.user_assigned_managed_identity_key
    subject                            = oidc_subject.subject
  } }
  oidc_subjects_flattened = flatten([for key, value in var.workflows : [
    for environment_user_assigned_managed_identity_mapping in value.environment_user_assigned_managed_identity_mappings :
    {
      subject_key                        = "${key}-${environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key}"
      user_assigned_managed_identity_key = environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key
      subject                            = "repo:${var.organization_name}/${var.repository_name}:environment:${var.environments[environment_user_assigned_managed_identity_mapping.environment_key]}:job_workflow_ref:${format(local.workflow_claim_structure, value.workflow_file_name)}"
    }
    ]
  ])
  organization_url = "https://github.com/${var.organization_name}"
  plan = {
    free       = "free"
    enterprise = "enterprise"
  }
  primary_approver = length(var.approvers) > 0 ? var.approvers[0] : ""
  ruleset_bypass = [
    for bypass in var.ruleset_bypass : {
      actor_id    = bypass.actor_type == "OrganizationAdmin" ? local.ruleset_bypass_actor_ids.organization_admin : lookup(local.ruleset_bypass_actor_ids, coalesce(bypass.role_name, "INVALID"), bypass.actor_id)
      actor_type  = bypass.actor_type
      bypass_mode = bypass.bypass_mode
    }
  ]
  ruleset_bypass_actor_ids = {
    admin              = 5
    write              = 4
    maintain           = 2
    organization_admin = 1
  }
  use_runner_group         = var.runner_group_enabled && data.github_organization.this.plan == local.plan.enterprise
  workflow_claim_structure = "${var.organization_name}/${var.repository_name}/%s@refs/heads/main"
}
