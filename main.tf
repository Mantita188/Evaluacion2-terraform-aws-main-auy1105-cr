# 1. LLAMADO AL MÓDULO REMOTO DE REDES (VPC)
module "network" {
  source               = "github.com/Mantita188/terraform-aws-vpc-auy1105-cr.git?ref=v0.1.1"
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_1_cidr = "10.0.1.0/24"
  public_subnet_2_cidr = "10.0.2.0/24"
  private_subnet_cidr  = "10.0.3.0/24"
  az_1                 = "us-east-1a"
  az_2                 = "us-east-1b"
}

# 2. LLAMADO AL MÓDULO REMOTO DE CÓMPUTO (EC2)
module "compute" {
  source    = "github.com/Mantita188/terraform-aws-ec2-auy1105-cr.git?ref=v0.1.4"
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.public_subnet_1_id
  alb_sg_id = module.network.alb_security_group_id
}

# 3. LLAMADO AL MÓDULO REMOTO DE ALMACENAMIENTO (S3)
module "storage" {
  source        = "github.com/Mantita188/terraform-aws-storage-auy1105-cr.git?ref=v0.1.1"
  environment   = var.environment
  bucket_prefix = "eval2-storage-cr"
}

# 4. LLAMADO AL NUEVO MÓDULO REMOTO DEL BALANCEADOR (ALB)
module "alb" {
  source                = "github.com/Mantita188/terraform-aws-alb-auy1105-cr.git?ref=v0.1.1"
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  alb_security_group_id = module.network.alb_security_group_id
  public_subnets        = [module.network.public_subnet_1_id, module.network.public_subnet_2_id]
  instance_id           = module.compute.instance_id
}