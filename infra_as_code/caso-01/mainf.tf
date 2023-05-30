###############################################
############ Bucket de producao ###############
###############################################

resource "aws_s3_bucket" "prod"{
    bucket = "estudos-aws-s3-prod"
    tags = merge(local.common_tags, {"Ambiente" = "Producao"})
}

resource "aws_s3_bucket_versioning" "versioning_prod" {
    bucket = aws_s3_bucket.prod.id
    versioning_configuration {
      status = "Enabled"
    }
}

###############################################
############ Bucket de homologacao ############
###############################################

resource "aws_s3_bucket" "homol"{
    bucket = "estudos-aws-s3-homol"
    tags = merge(local.common_tags, {"Ambiente" = "Homologacao"})
}

resource "aws_s3_bucket_versioning" "versioning_homol" {
    bucket = aws_s3_bucket.homol.id
    versioning_configuration {
      status = "Disabled"
    }
}

###############################################
########## Bucket de desenvolvimento ##########
###############################################

resource "aws_s3_bucket" "dev"{
    bucket = "estudos-aws-s3-dev"
    tags = merge(local.common_tags, {"Ambiente" = "Desenvolvimento"})
}

resource "aws_s3_bucket_versioning" "versioning_dev" {
    bucket = aws_s3_bucket.dev.id
    versioning_configuration {
      status = "Disabled"
    }
}

resource "aws_s3_bucket_ownership_controls" "owner_dev" {
  bucket = aws_s3_bucket.dev.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "pub_dev" {
  bucket = aws_s3_bucket.dev.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "acl_dev" {
  depends_on = [
    aws_s3_bucket_ownership_controls.owner_dev,
    aws_s3_bucket_public_access_block.pub_dev,
  ]

  bucket = aws_s3_bucket.dev.id
  acl    = "public-read"
}