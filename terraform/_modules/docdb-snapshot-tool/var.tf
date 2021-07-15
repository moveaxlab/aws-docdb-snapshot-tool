variable "environment" {
  type = string
  description = "Environment"
}

variable "stack_name" {
  type = string
  description = "CloudFormation stack name"
}

variable "code_bucket" {
  type = string
  description = "S3 bucket identifier"
}

variable "cftemplate_name" {
  type = string
  description = "CloudFormation template filename"
}

variable "repo_base_url" {
  type = string
  description = "Base URL containing artifacts"
}

variable "repo_release_version" {
  type = string
  description = "Repository release version identifier"
}

variable "region" {
  type = string
  description = "AWS region name"
}

variable "dr_region" {
  type = string
  description = "AWS disaster recovery region name"
}

variable "regionOverride" {
  type = string
  description = "AWS region name that overrides values in region and dr_region vars"
}

variable "namePattern" {
  type = string
  description = "Regex for matching cluster identifiers to backup"
}

variable "backupInterval" {
  type = string
  description = "Interval for backups in hours. Default is 24"
}

variable "retention_days" {
  type = number
  description = "Number of days to keep snapshots in retention before deleting them"
}

variable "artifact_path" {
  type = string
  description = "Path to downloaded artifacts"
}

variable "tags" {
  type = map(string)
  description = "tags"
}