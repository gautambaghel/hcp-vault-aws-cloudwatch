variable "region" {
  description = "AWS region"
  default = "us-east-2"
}

variable "user_email" {
  description = "User email address"
}

variable "hcp_org_id" {
  description = "The Id of the HCP Organization to attach audit logs"
}

variable "hcp_project_id" {
  description = "The Id of the HCP Project to attach audit logs"
}
