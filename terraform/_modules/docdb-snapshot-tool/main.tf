resource "null_resource" "zip_downloader" {
  provisioner "local-exec" {
    # Bootstrap script that downloads zip files
    command = "wget -O ${var.lambda_zip_path}/copy_snapshots_dest_docdb.zip ${var.zip_repo_url}/${var.zip_repo_version}/copy_snapshots_dest_docdb.zip && wget -O ${var.lambda_zip_path}/delete_old_snapshots_docdb.zip ${var.zip_repo_url}/${var.zip_repo_version}/delete_old_snapshots_docdb.zip"
  }

  triggers = {
    repo = var.zip_repo_url,
    version = var.zip_repo_version
  }
}

resource "aws_s3_bucket_object" "lambda_copy" {
  bucket        = var.code_bucket
  key           = "copy_snapshots_dest_docdb.zip"
  source        = "${var.lambda_zip_path}/copy_snapshots_dest_docdb.zip"
  tags          = var.tags
  depends_on    = [null_resource.zip_downloader]
}

resource "aws_s3_bucket_object" "lambda_delete" {
  bucket        = var.code_bucket
  key           = "delete_old_snapshots_docdb.zip"
  source        = "${var.lambda_zip_path}/delete_old_snapshots_docdb.zip"
  tags          = var.tags
  depends_on    = [null_resource.zip_downloader]
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

