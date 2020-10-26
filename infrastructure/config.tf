variable "aws_region" {
  default = "eu-west-1"
}

variable "availability_zones" {
  type    = list(string)
  default = ["a", "b", "c"]
}

variable "project_name" {
  default = "redash"
}

variable "base_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cdir_block" {
  description = "List of public subenets"
  default     = [1, 2, 3]
}

variable "subet_mask_bit" {
  default = 8
}


variable "public_subnets" {
  description = "Map from availability zone to the number that should be used for each availability zone's subnet"
  default = {
    "a" = 1
    "b" = 2
    "c" = 3
  }
}

variable "private_subnets" {
  description = "Map from availability zone to the number that should be used for each availability zone's subnet"
  default = {
    "a" = 11
    "b" = 22
    "c" = 33
  }
}
