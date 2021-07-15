resource "null_resource" "zip_downloader" {
  provisioner "local-exec" {
    # Bootstrap script that downloads zip files
    command = "wget -O ${var.artifact_path}/${var.cftemplate_name} ${var.repo_base_url}/${var.repo_release_version}/${var.cftemplate_name} && wget -O ${var.artifact_path}/copy_snapshots_dest_docdb.zip ${var.repo_base_url}/${var.repo_release_version}/copy_snapshots_dest_docdb.zip && wget -O ${var.artifact_path}/delete_old_snapshots_docdb.zip ${var.repo_base_url}/${var.repo_release_version}/delete_old_snapshots_docdb.zip"
  }

  triggers = {
    repo = var.repo_base_url,
    version = var.repo_release_version,
    cftemplate = var.cftemplate_name
  }
}

resource "aws_s3_bucket_object" "lambda_copy" {
  bucket        = var.code_bucket
  key           = "copy_snapshots_dest_docdb.zip"
  source        = "${var.artifact_path}/copy_snapshots_dest_docdb.zip"
  tags          = var.tags
  depends_on    = [null_resource.zip_downloader]
}

resource "aws_s3_bucket_object" "lambda_delete" {
  bucket        = var.code_bucket
  key           = "delete_old_snapshots_docdb.zip"
  source        = "${var.artifact_path}/delete_old_snapshots_docdb.zip"
  tags          = var.tags
  depends_on    = [null_resource.zip_downloader]
}

resource "aws_s3_bucket_object" "cf_template" {
  bucket        = var.code_bucket
  key           = var.cftemplate_name
  source        = "${var.artifact_path}/${var.cftemplate_name}"
  tags          = var.tags
  depends_on    = [null_resource.zip_downloader]
}

resource "aws_cloudformation_stack" "network" {
  name          = var.stack_name
  capabilities  = ["CAPABILITY_IAM"]
  parameters    = {
    Environment = var.environment,
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
  
  template_url  = "https://${var.code_bucket}.s3-${var.region}.amazonaws.com/${var.cftemplate_name}"
  depends_on    = [aws_s3_bucket_object.lambda_copy, aws_s3_bucket_object.lambda_delete, aws_s3_bucket_object.cf_template]
  tags          = var.tags
}

