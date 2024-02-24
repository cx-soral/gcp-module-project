terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
  }
}

locals {
  landscape = yamldecode(file(var.landscape_file))
  applications = yamldecode(file(var.applications_file))
  project_prefix = local.landscape["settings"]["project_prefix"]
  billing_account = local.landscape["settings"]["billing_account"]
  environment_dict = local.landscape["environments"]
}

locals {
  all_pool_settings = toset(flatten([
    for app_name, app in local.applications : [
      for env_name, env in local.environment_dict : {
        app_name          = app_name
        env_name          = env_name
        repository_owner  = app["repository_owner"]
        repository_name   = app["repository_name"]
        project_id        = "${local.project_prefix}${env_name}"
        match_branch      = env["match_branch"]
      }
    ]
  ]))
}

resource "google_project" "env_projects" {
  for_each = local.environment_dict

  name = "${local.project_prefix}${each.key}"
  project_id = "${local.project_prefix}${each.key}"
  billing_account = local.billing_account
}