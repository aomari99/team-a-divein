terraform {
  backend "s3" {
    bucket = "wordpress-teama"
    region = "eu-west-1"
  }
}
provider "aws" {
  region = local.region
}

