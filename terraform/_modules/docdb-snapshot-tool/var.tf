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

variable "cftemplates_path" {
  type = string
  description = "CloudFormation template location path"
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

variable "lambda_zip_path" {
  type = string
  description = "Path to zipped lambda functions"
}

variable "tags" {
  type = map(string)
  description = "tags"
}

variable "zip_repo_url" {
  type = string
  description = "Repository URL containing zip files"
}

variable "zip_repo_version" {
  type = string
  description = "Repository release version identifier"
}