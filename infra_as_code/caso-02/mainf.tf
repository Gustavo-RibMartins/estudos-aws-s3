# create bucket

resource "aws_s3_bucket" "s3devsecops" {
  bucket = "estudos-aws-s3-devsecops"
  tags = {
    "terraform" : "true"
  }
}

# attach policy to bucket

resource "aws_s3_bucket_policy" "s3devsecops_bucket_policy" {
  bucket = aws_s3_bucket.s3devsecops.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "Allow-DevSecOps-Access"
        Effect    = "Allow"
        Principal = "arn:aws:iam::614167850029:user/devsecops"
        Actions = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resources = [
          aws_s3_bucket.s3devsecops.arn,
          "${aws_s3_bucket.s3devsecops.arn}/*"
        ]
      },
      {
        Sid       = "Deny-Access-OtherUsers"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resources = [
          aws_s3_bucket.s3devsecops.arn,
          "${aws_s3_bucket.s3devsecops.arn}/*"
        ]
        Condition = {
          "ForAnyValue:StringNotLikeIfExists" : {
            "aws:username" : "DevSecOps"
          }
        }
      },
      {
        Sid       = "Block-Upload-Without-KMS-Encryption"
        Effect    = "Deny"
        Principal = "*"
        Action    = "S3:*"
        Resources = [
          aws_s3_bucket.s3devsecops.arn,
          "${aws_s3_bucket.s3devsecops.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" : "aws:kms"
          }
        }
      },
      {
        Sid       = "Block-No-SSL-Transport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resources = [
          aws_s3_bucket.s3devsecops.arn,
          "${aws_s3_bucket.s3devsecops.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransporte" : "false"
          }
        }
      }
    ]
  })
}