variable "rancher_api" {
  description = "API endpoint"
}

variable "rancher_key" {
  description = "Rancher access key"
}

variable "rancher_secret" {
  description = "Rancher secret key"
}

variable "rancher_env" {
  description = "Rancher environment"
  default = "Default"
}

variable "rancher_stack" {
  description = "Rancher stack name"
  default = "tzurl"
}
