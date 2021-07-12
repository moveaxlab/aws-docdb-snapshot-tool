resource "aws_s3_bucket_object" "lambda_copy" {
  bucket        = var.code_bucket
  key           = "copy_snapshots_dest_docdb.zip"
  source        = "${var.lambda_zip_path}/copy_snapshots_dest_docdb.zip"
  etag          = filemd5("${var.lambda_zip_path}/copy_snapshots_dest_docdb.zip")
  tags          = var.tags
}

resource "aws_s3_bucket_object" "lambda_delete" {
  bucket        = var.code_bucket
  key           = "delete_old_snapshots_docdb.zip"
  source        = "${var.lambda_zip_path}/delete_old_snapshots_docdb.zip"
  etag          = filemd5("${var.lambda_zip_path}/delete_old_snapshots_docdb.zip")
  tags          = var.tags
}

resource "aws_cloudformation_stack" "network" {
  name          = var.stack_name
  capabilities  = ["CAPABILITY_IAM"]
  parameters    = {
    CodeBucket = var.code_bucket,
    Region = var.region,
    DrRegion = var.dr_region,
    RegionOverride = var.regionOverride,
    InstanceNamePattern = var.namePattern,
    SnapshotNamePattern = var.namePattern,
    BackupInterval = var.backupInterval,
    TaggedInstance = "FALSE",
    LogLevel = "ERROR",
    RetentionDays = var.retention_days 
  }
  template_body = file("${var.cftemplates_path}/${var.cftemplate_name}")
  depends_on    = [aws_s3_bucket_object.lambda_copy, aws_s3_bucket_object.lambda_delete]
  tags          = var.tags
}

