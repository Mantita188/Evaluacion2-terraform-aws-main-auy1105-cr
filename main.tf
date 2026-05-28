terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Traer la capa remota de Redes desde GitHub apuntando a la rama main
module "networking" {
  source = "github.com/Mantita188/terraform-aws-vpc-auy1105-cr?ref=main"
}

# 2. Traer la capa remota de Computo inyectando los outputs de redes
module "compute" {
  source    = "github.com/Mantita188/terraform-aws-ec2-auy1105-cr?ref=main"
  vpc_id    = module.networking.vpc_id
  subnet_id = module.networking.primary_public_subnet_id
  alb_sg_id = module.networking.alb_sg_id
}

# 3. Traer la capa remota del modulo especifico Storage
module "storage" {
  source        = "github.com/Mantita188/terraform-aws-storage-auy1105-cr?ref=main"
  bucket_prefix = "mi-bucket-prueba2"
}

# ─── RECURSOS CORE: APPLICATION LOAD BALANCER (Alto Nivel) ────────────────────
resource "aws_lb" "main" {
  name               = "alb-prueba2-cr"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.networking.alb_sg_id]
  subnets            = module.networking.public_subnet_ids
}

resource "aws_lb_target_group" "web" {
  name     = "tg-web-prueba2-cr"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.networking.vpc_id

  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    matcher  = "200"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = module.compute.instance_id
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}