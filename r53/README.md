<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cdn_name"></a> [cdn\_name](#input\_cdn\_name) | CDN name | `string` | n/a | yes |
| <a name="input_cdn_zone_id"></a> [cdn\_zone\_id](#input\_cdn\_zone\_id) | CDN Zone ID | `string` | `"Z2FDTNDATAQYW2"` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Hosted zone id | `string` | `""` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->