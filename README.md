# PingFederate Terraform Module

A Terraform module to deploy PingFederate on AWS behind an NLB with TLS termination via ACM.

<!-- BEGIN_TF_DOCS -->
## Usage

### main.tf
```hcl
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
```

## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_bastion_allowed_cidrs"></a> [bastion\_allowed\_cidrs](#input\_bastion\_allowed\_cidrs) | CIDR blocks allowed to SSH to the bastion host. | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_bastion_instance_type"></a> [bastion\_instance\_type](#input\_bastion\_instance\_type) | EC2 instance type for the bastion host. | `string` | `"t3.micro"` | no |
| <a name="input_common_tags"></a> [common\_tags](#input\_common\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |
| <a name="input_ec2_ami"></a> [ec2\_ami](#input\_ec2\_ami) | AMI to use for EC2 instances. Must be Ubuntu or Debian-based. | <pre>object({<br/>    id   = string<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_ec2_key_pair_name"></a> [ec2\_key\_pair\_name](#input\_ec2\_key\_pair\_name) | Name of an existing EC2 key pair for SSH access. | `string` | n/a | yes |
| <a name="input_existing_vpc"></a> [existing\_vpc](#input\_existing\_vpc) | Existing VPC to deploy into. When null (default), a new VPC is created.<br/>The existing VPC must already have the required VPC endpoints: S3 (Gateway). | <pre>object({<br/>    vpc_id             = string<br/>    private_subnet_ids = list(string)<br/>    public_subnet_ids  = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_nlb_internal"></a> [nlb\_internal](#input\_nlb\_internal) | Whether the NLB is internal. | `bool` | `true` | no |
| <a name="input_pingfederate_allowed_cidrs"></a> [pingfederate\_allowed\_cidrs](#input\_pingfederate\_allowed\_cidrs) | CIDR blocks allowed to reach PingFederate (ports 9999 and 9031) from outside the VPC. Only effective when nlb\_internal is false. | `list(string)` | `[]` | no |
| <a name="input_pingfederate_instance_type"></a> [pingfederate\_instance\_type](#input\_pingfederate\_instance\_type) | EC2 instance type for the PingFederate instance. | `string` | `"t3.medium"` | no |
| <a name="input_pingfederate_license_key"></a> [pingfederate\_license\_key](#input\_pingfederate\_license\_key) | S3 object key for the PingFederate license file. | `string` | n/a | yes |
| <a name="input_pingfederate_subdomain"></a> [pingfederate\_subdomain](#input\_pingfederate\_subdomain) | Subdomain for the PingFederate DNS record. | `string` | `"pingfed"` | no |
| <a name="input_pingfederate_zip_key"></a> [pingfederate\_zip\_key](#input\_pingfederate\_zip\_key) | S3 object key for the PingFederate distribution zip file. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name prefix for all resources. | `string` | n/a | yes |
| <a name="input_route53_zone"></a> [route53\_zone](#input\_route53\_zone) | Route 53 hosted zone for the PingFederate DNS record. | <pre>object({<br/>    zone_id = string<br/>    name    = string<br/>  })</pre> | n/a | yes |
| <a name="input_s3_artifact_bucket"></a> [s3\_artifact\_bucket](#input\_s3\_artifact\_bucket) | Name of the S3 bucket containing PingFederate distribution artifacts. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_private_subnets"></a> [vpc\_private\_subnets](#input\_vpc\_private\_subnets) | Private subnet CIDR blocks. | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_vpc_public_subnets"></a> [vpc\_public\_subnets](#input\_vpc\_public\_subnets) | Public subnet CIDR blocks. | `list(string)` | <pre>[<br/>  "10.0.101.0/24",<br/>  "10.0.102.0/24",<br/>  "10.0.103.0/24"<br/>]</pre> | no |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_acm_certificate.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_iam_instance_profile.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.pingfederate_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_lb_target_group_attachment.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.cert_validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.pingfederate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_security_group_egress_rule.bastion_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.pingfederate_all](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.bastion_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_admin_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_runtime_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.pingfederate_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_iam_policy_document.pingfederate_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.pingfederate_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bastion_public_ip"></a> [bastion\_public\_ip](#output\_bastion\_public\_ip) | Public IP of the bastion host. |
| <a name="output_ec2_ami_name"></a> [ec2\_ami\_name](#output\_ec2\_ami\_name) | Name of the AMI used for EC2 instances. |
| <a name="output_pingfederate_admin_url"></a> [pingfederate\_admin\_url](#output\_pingfederate\_admin\_url) | URL of the PingFederate admin console. |
| <a name="output_pingfederate_instance_id"></a> [pingfederate\_instance\_id](#output\_pingfederate\_instance\_id) | Instance ID of the PingFederate instance. |
| <a name="output_pingfederate_private_ip"></a> [pingfederate\_private\_ip](#output\_pingfederate\_private\_ip) | Private IP of the PingFederate instance. |
| <a name="output_pingfederate_runtime_url"></a> [pingfederate\_runtime\_url](#output\_pingfederate\_runtime\_url) | URL of the PingFederate runtime engine. |
<!-- END_TF_DOCS -->
