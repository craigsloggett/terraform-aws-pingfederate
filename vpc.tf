module "vpc" {
  count = var.existing_vpc == null ? 1 : 0

  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.project_name}-pingfederate"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = var.common_tags
}

# VPC Endpoints

resource "aws_vpc_endpoint" "s3" {
  count = var.existing_vpc == null ? 1 : 0

  vpc_id            = module.vpc[0].vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = module.vpc[0].private_route_table_ids

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-s3" })
}

# Security Groups

resource "aws_security_group" "bastion" {
  name_prefix = "${var.project_name}-pingfederate-bastion-"
  description = "Security group for the bastion host"
  vpc_id      = local.vpc.id

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate-bastion" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  for_each = toset(var.bastion_allowed_cidrs)

  security_group_id = aws_security_group.bastion.id
  description       = "SSH from allowed CIDR"
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "bastion_all" {
  security_group_id = aws_security_group.bastion.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "pingfederate" {
  name_prefix = "${var.project_name}-pingfederate-"
  description = "Security group for the PingFederate instance"
  vpc_id      = local.vpc.id

  tags = merge(var.common_tags, { Name = "${var.project_name}-pingfederate" })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_admin" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate admin console from VPC"
  from_port         = 9999
  to_port           = 9999
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpc.cidr
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_admin_external" {
  for_each = toset(var.pingfederate_allowed_cidrs)

  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate admin console from external CIDR"
  from_port         = 9999
  to_port           = 9999
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_runtime" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate runtime engine from VPC"
  from_port         = 9031
  to_port           = 9031
  ip_protocol       = "tcp"
  cidr_ipv4         = local.vpc.cidr
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_runtime_external" {
  for_each = toset(var.pingfederate_allowed_cidrs)

  security_group_id = aws_security_group.pingfederate.id
  description       = "PingFederate runtime engine from external CIDR"
  from_port         = 9031
  to_port           = 9031
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_ingress_rule" "pingfederate_ssh" {
  security_group_id            = aws_security_group.pingfederate.id
  description                  = "SSH from bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_egress_rule" "pingfederate_all" {
  security_group_id = aws_security_group.pingfederate.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
