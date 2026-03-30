data "aws_route53_zone" "selected" {
  name = var.route53_zone_name
}

data "aws_ami" "selected" {
  most_recent = true
  owners      = [var.ec2_ami_owner]

  filter {
    name   = "name"
    values = [var.ec2_ami_name]
  }
}

module "pingfederate" {
  # tflint-ignore: terraform_module_pinned_source
  source = "git::https://github.com/craigsloggett/terraform-aws-pingfederate"

  project_name      = var.project_name
  route53_zone      = data.aws_route53_zone.selected
  ec2_key_pair_name = var.ec2_key_pair_name
  ec2_ami           = data.aws_ami.selected

  s3_artifact_bucket       = var.s3_artifact_bucket
  pingfederate_zip_key     = var.pingfederate_zip_key
  pingfederate_license_key = var.pingfederate_license_key

  nlb_internal               = var.nlb_internal
  pingfederate_allowed_cidrs = var.pingfederate_allowed_cidrs
}
