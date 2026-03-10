mock_provider "aws" {}

variables {
  project_name = "vcode"
  environment  = "test"
}

run "bucket_versioning_enabled" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = aws_s3_bucket_versioning.backups.versioning_configuration[0].status == "Enabled"
    error_message = "Bucket versioning should be enabled"
  }
}

run "bucket_encryption_kms" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.backups.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"
    error_message = "Bucket should use KMS encryption"
  }
}

run "bucket_public_access_blocked" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.block_public_acls == true
    error_message = "Public ACLs should be blocked"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.block_public_policy == true
    error_message = "Public policy should be blocked"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.ignore_public_acls == true
    error_message = "Public ACLs should be ignored"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.backups.restrict_public_buckets == true
    error_message = "Public buckets should be restricted"
  }
}

run "bucket_has_ssl_only_policy" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = aws_s3_bucket_policy.deny_non_ssl.bucket == aws_s3_bucket.backups.id
    error_message = "Bucket policy should enforce SSL-only access"
  }
}

run "bucket_lifecycle_has_transitions" {
  command = plan

  module {
    source = "./modules/s3_backup"
  }

  assert {
    condition     = one(aws_s3_bucket_lifecycle_configuration.backups.rule).status == "Enabled"
    error_message = "Lifecycle rule should be enabled"
  }

  assert {
    condition     = one(aws_s3_bucket_lifecycle_configuration.backups.rule).id == "backup-lifecycle"
    error_message = "Lifecycle rule should have correct ID"
  }
}