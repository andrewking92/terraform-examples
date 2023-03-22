provider "aws" {
  region = var.aws_region
}


module "setup" {
  source = "./modules/setup"
}


module "mongod01" {
  source = "./modules/mongod"

  subnet_id = module.setup.aws-subnet-infra-aws-mongodb-id
  security_group_id = module.setup.aws-security-group-infra-aws-mongodb-id

  FQDN = "mongod01.kingan916.com"
  instance_name = "mongod-server-01"
}


module "mongod02" {
  source = "./modules/mongod"

  subnet_id = module.setup.aws-subnet-infra-aws-mongodb-id
  security_group_id = module.setup.aws-security-group-infra-aws-mongodb-id

  FQDN = "mongod02.kingan916.com"
  instance_name = "mongod-server-02"
}


module "mongod03" {
  source = "./modules/mongod"

  subnet_id = module.setup.aws-subnet-infra-aws-mongodb-id
  security_group_id = module.setup.aws-security-group-infra-aws-mongodb-id

  FQDN = "mongod03.kingan916.com"
  instance_name = "mongod-server-03"
}
