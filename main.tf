module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  environment = var.environment
  vpc_cidr = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones = var.availability_zones
}

module "security_groups" {
  source = "./modules/security-groups"

  project_name = var.project_name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
}

module "alb" {
  source = "./modules/alb"

  project_name = var.project_name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_sg_id = module.security_groups.alb_sg_id
}

module "asg" {
  source = "./modules/asg"

  project_name = var.project_name
  environment = var.environment
  vpc_id = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ec2_sg_id = module.security_groups.ec2_sg_id
  target_group_arn = module.alb.target_group_arn
  instance_type = "t2.micro"
}

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  environment = var.environment
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id = module.security_groups.rds_sg_id
  db_name = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_instance_class = "db.t3.micro"
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment = var.project_name
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
  environment = var.environment
  asg_name = module.asg.asg_name
}