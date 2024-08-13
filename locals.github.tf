locals {
  github_apply_key = "apply"

  github_free_plan = "free"

  github_enterprise_plan = "enterprise"

  #use_runner_group = var.use_runner_group && data.github_organization.alz.plan == local.enterprise_plan && var.use_self_hosted_runners

  primary_approver = length(var.github_approvers) > 0 ? var.github_approvers[0] : ""

  default_commit_email = coalesce(local.primary_approver, "demo@microsoft.com")

  github_repositoru_ruleset_bypass_actor_ids = {
    admin              = 5
    write              = 4
    maintain           = 2
    organization_admin = 1
  }

  github_repository_ruleset_bypass = [
    for bypass in var.github_respository_ruleset_bypass : {
      actor_id    = bypass.actor_type == "OrganizationAdmin" ? local.github_repositoru_ruleset_bypass_actor_ids : lookup(local.github_repositoru_ruleset_bypass_actor_ids, bypass.role_name, null)
      actor_type  = bypass.actor_type
      bypass_mode = bypass.bypass_mode
    }
  ]

  #repository_name_templates = var.use_template_repository ? var.repository_name_templates : var.github_repository_name
  #template_claim_structure  = "${var.github_organization_name}/${local.repository_name_templates}/%s@refs/heads/main"

  # oidc_subjects_flattened = flatten([for key, value in var.workflows : [
  #   for environment_user_assigned_managed_identity_mapping in value.environment_user_assigned_managed_identity_mappings :
  #   {
  #     subject_key                        = "${key}-${environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key}"
  #     user_assigned_managed_identity_key = environment_user_assigned_managed_identity_mapping.user_assigned_managed_identity_key
  #     subject                            = "repo:${var.github_organization_name}/${var.github_organization_name}:environment:${var.environments[environment_user_assigned_managed_identity_mapping.environment_key]}:job_workflow_ref:${format(local.template_claim_structure, value.workflow_file_name)}"
  #   }
  #   ]
  # ])

  # oidc_subjects = { for oidc_subject in local.oidc_subjects_flattened : oidc_subject.subject_key => {
  #   user_assigned_managed_identity_key = oidc_subject.user_assigned_managed_identity_key
  #   subject                            = oidc_subject.subject
  # } }

  #runner_group_name = local.use_runner_group ? github_actions_runner_group.alz[0].name : var.default_runner_group_name

}
