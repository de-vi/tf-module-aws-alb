## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_log\_bucket | n/a | `any` | n/a | yes |
| name | n/a | `any` | n/a | yes |
| sg\_ids | n/a | `any` | n/a | yes |
| ssl\_cert\_arn | n/a | `any` | n/a | yes |
| subnet\_ids | A list of subnet ids | `list(string)` | n/a | yes |
| vpc\_id | VPC id | `string` | n/a | yes |
| tags | A list of tags | `map(string)` | `{}` | no |
| target\_group\_health\_checks | A list of target group health check | `list(map(string))` | `[]` | no |
| target\_groups | A list of target group maps | `list(map(string))` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| lb\_dns\_name | n/a |
| lb\_dns\_zone\_id | n/a |
| target\_group\_arn | n/a |
