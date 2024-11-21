#===================================================================
# S3 Frontend Nuxt3 App Build Artifacts Bucket
#===================================================================
# Create an S3 bucket to store the build artifacts of the Nuxt3 app
resource "aws_s3_bucket" "build_artifacts" {
  bucket = "nuxt3-app-build-artifacts"

  tags = {
    Name        = "Nuxt3 App Build Artifacts"
    Environment = var.environment
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.build_artifacts.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Define bucket policy (only allow access for 'iot-user')
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.build_artifacts.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::474412366603:user/iot-user"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.build_artifacts.id}",
        "arn:aws:s3:::${aws_s3_bucket.build_artifacts.id}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Principal": {
         "AWS": "${var.amplify_role_arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.build_artifacts.id}",
        "arn:aws:s3:::${aws_s3_bucket.build_artifacts.id}/*"
      ]
    }
  ]
}
POLICY
}

# Upload the build artifacts to S3
resource "aws_s3_object" "build_zip" {
  bucket       = aws_s3_bucket.build_artifacts.id
  key          = "nuxt3-csr-build.zip"
  source       = "${path.root}/../frontend/dist/nuxt3-csr-build.zip"
  content_type = "application/zip"

  tags = {
    Name        = "Nuxt3 Build Artifact"
    Environment = var.environment
  }
}