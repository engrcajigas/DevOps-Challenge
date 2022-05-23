data "template_file" "iam_policy_template" {
  template = file("${path.module}/iam_policy.json")
  vars = {
    s3_bucket_name = var.s3_bucket_name
  }

}