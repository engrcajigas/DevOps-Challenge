resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "${var.tag_name_prefix}-s3-bucket-policy"
  path        = "/"
  description = "Allow Read Files to S3 Bucket"

  policy = data.template_file.iam_policy_template.rendered
}

resource "aws_iam_role" "role" {
  name               = "${var.tag_name_prefix}-iam-role"
  assume_role_policy = file("${path.module}/iam_role.json")
}

resource "aws_iam_role_policy_attachment" "bucket_policy" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.tag_name_prefix}-ec2-instance-profile"
  role = aws_iam_role.role.name
}