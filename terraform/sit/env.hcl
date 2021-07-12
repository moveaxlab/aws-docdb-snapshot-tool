locals {
  environment                   = "sit"

  # DOCDB Snapshot tools
  snaptool_stack_name           = "docdb-snaptool"
  snaptool_code_bucket          = "s3-bucket-code"
  snaptool_cftemplate_name      = "snapshot_tool_docdb_copy_and_delete.json"
  snaptool_region               = "eu-central-1"
  snaptool_dr_region            = "eu-west-1"
  snaptool_regionOverride       = "NO"
  snaptool_namePattern          = "sit"
  snaptool_backupInterval       = "24"
  snaptool_retention_days       = 7
}