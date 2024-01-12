# create user
resource "aws_iam_user" "devsecops" {
  name = "devsecops"

  tags = {
    terraform = "true"
  }
}

# create access key
resource "aws_iam_access_key" "devsecops" {
  user = aws_iam_user.devsecops.name
}

output "secret" {
  value = aws_iam_access_key.devsecops.encrypted_secret
}

# json policy
data "aws_iam_policy_document" "devsecops_list_buckets" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["arn:aws:s3:::*"]
  }
}

# policy to attach to user
resource "aws_iam_user_policy" "devsecops_policy" {
  name   = "devsecops_policy"
  user   = aws_iam_user.devsecops.name
  policy = data.aws_iam_policy_document.devsecops_list_buckets.json
}
