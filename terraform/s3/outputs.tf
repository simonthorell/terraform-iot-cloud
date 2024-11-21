#===================================================================
# S3 Outputs
#===================================================================
output "bucket_name" {
  value = aws_s3_bucket.build_artifacts.bucket
}

output "object_key" {
  value = aws_s3_object.build_zip.key
}