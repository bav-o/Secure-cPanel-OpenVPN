output "bucket_id" {
  description = "ID of the S3 backup bucket"
  value       = aws_s3_bucket.backups.id
}

output "bucket_arn" {
  description = "ARN of the S3 backup bucket"
  value       = aws_s3_bucket.backups.arn
}

output "bucket_name" {
  description = "Name of the S3 backup bucket"
  value       = aws_s3_bucket.backups.bucket
}
