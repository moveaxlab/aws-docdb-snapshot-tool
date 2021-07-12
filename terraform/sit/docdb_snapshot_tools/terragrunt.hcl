terraform {
  source = "${path_relative_from_include()}/_modules//docdb-snapshot-tool"
}

# Include all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders()
}


locals {
  # Automatically load environment-level variables
  environment_vars      = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  environment           = local.environment_vars.locals.environment
  repo_base_url         = "https://github.com/moveaxlab/aws-docdb-snapshot-tool/releases/download"
  cftemplate_name       = local.environment_vars.locals.snaptool_cftemplate_name
  stack_name            = local.environment_vars.locals.snaptool_stack_name
  code_bucket           = local.environment_vars.locals.snaptool_code_bucket
  region                = local.environment_vars.locals.snaptool_region
  dr_region             = local.environment_vars.locals.snaptool_dr_region
  regionOverride        = local.environment_vars.locals.snaptool_regionOverride
  namePattern           = local.environment_vars.locals.snaptool_namePattern
  backupInterval        = local.environment_vars.locals.snaptool_backupInterval
  retention_days        = local.environment_vars.locals.snaptool_retention_days
  artifact_path         = "${get_terragrunt_dir()}/artifacts"
  repo_release_version  = local.environment_vars.locals.snaptool_repo_release_version

  tags                  = {
    environment = "${local.environment}"
    context = "docdb"
    snaptool-version = "${local.repo_release_version}"
  }
}


inputs = merge(
  local.environment_vars.locals,
  local
)
