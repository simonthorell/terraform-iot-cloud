#===================================================================
# S3 Frontend Nuxt3 App Build Artifacts Bucket
#===================================================================
# S3 Bucket for Build Artifacts
resource "aws_s3_bucket" "build_artifacts" {
  bucket = "nuxt3-app-build-artifacts"

  tags = {
    Name        = "Nuxt3 App Build Artifacts"
    Environment = var.environment
  }
}

# Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "build_artifacts" {
  bucket = aws_s3_bucket.build_artifacts.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public Access Block (Disabled if Public Access is Required)
resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.build_artifacts.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false
  restrict_public_buckets = false
}

# Bucket Policy (Grant Amplify Access)
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.build_artifacts.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "amplify.amazonaws.com"
      },
      "Action": [
        "s3:ListBucket",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::nuxt3-app-build-artifacts",
        "arn:aws:s3:::nuxt3-app-build-artifacts/*"
      ]
    },
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::nuxt3-app-build-artifacts",
        "arn:aws:s3:::nuxt3-app-build-artifacts/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
POLICY
}

# Upload Build Artifacts to S3
resource "aws_s3_object" "build_zip" {
  bucket       = aws_s3_bucket.build_artifacts.id
  key          = "nuxt3-csr-build.zip"
  source       = "${path.root}/../frontend/dist/nuxt3-csr-build.zip"
  content_type = "application/zip"
  # acl          = "private" # Use private and control access via bucket policy
  acl          = "public-read" # Public read access


  tags = {
    Name        = "Nuxt3 Build Artifact"
    Environment = var.environment
  }
}