variable "access_key" {
  type = "string"
}

variable "secret_key" {
  type = "string"
}

variable "region" {
  type = "string"
}

variable "concourse_inbound_cidr" {
  default = "0.0.0.0/0"
}

variable "availability_zones" {
  type = "list"
}

variable "env_id" {
  type = "string"
}

variable "vpc_cidr" {
  type    = "string"
  default = "10.0.0.0/16"
}

variable "existing_vpc_id" {
  type        = "string"
  default     = ""
  description = "Optionally use an existing vpc"
}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"

  version = ">= 1.17.0"
}
