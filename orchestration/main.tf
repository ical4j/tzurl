provider "rancher" {
  api_url = "${var.rancher_api}"
  access_key = "${var.rancher_key}"
  secret_key = "${var.rancher_secret}"
}

data "rancher_environment" "rancher_env" {
  name = "${var.rancher_env}"
}

resource "rancher_stack" "tzurl" {
  environment_id = "${data.rancher_environment.rancher_env.id}"
  name = "${var.rancher_stack}"
  docker_compose = "${file("rancher/docker-compose.yml")}"
  rancher_compose = "${file("rancher/rancher-compose.yml")}"
  start_on_create = true
}
