provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_api_pub_key
  private_key = var.mongodb_atlas_api_pri_key
}


provider "aws" {
  region = var.aws_region
}


module "encryption-at-rest" {
  source = "./modules/encryption-at-rest"
}