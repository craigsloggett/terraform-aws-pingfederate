# Bastion Host

resource "aws_instance" "bastion" {
  ami                         = var.ec2_ami.id
  instance_type               = var.bastion_instance_type
  key_name                    = var.ec2_key_pair_name
  subnet_id                   = local.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-bastion" })
}

# PingFederate Instance

resource "aws_instance" "pingfederate" {
  ami                    = var.ec2_ami.id
  instance_type          = var.pingfederate_instance_type
  key_name               = var.ec2_key_pair_name
  subnet_id              = local.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.pingfederate.id]
  iam_instance_profile   = aws_iam_instance_profile.pingfederate.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  user_data = templatefile("${path.module}/templates/cloud-init.sh.tftpl", {
    region                   = data.aws_region.current.region
    s3_bucket                = var.s3_artifact_bucket
    pingfederate_zip_key     = var.pingfederate_zip_key
    pingfederate_license_key = var.pingfederate_license_key
  })

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })

  depends_on = [
    aws_iam_role_policy.pingfederate_s3,
  ]

  lifecycle {
    precondition {
      condition     = can(regex("(ubuntu|debian)", lower(var.ec2_ami.name)))
      error_message = "The provided AMI must be Ubuntu or Debian-based."
    }
  }
}
