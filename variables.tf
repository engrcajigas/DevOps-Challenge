variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}

variable "region" {
  description = "AWS Region where terraform templates will be deployed"
  default     = "us-east-1"
}

variable "profile" {
  type        = string
  description = "AWS profile that will be used"
  default     = "stephane"
}
