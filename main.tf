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
  source                = "github.com/Mantita188/terraform-aws-ec2-auy1105-cr.git?ref=v0.1.1"
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  public_subnet_id      = module.network.public_subnet_1_id
  alb_security_group_id = module.network.alb_security_group_id
  ami_id                = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS en us-east-1
  instance_type         = "t2.micro"
}

# 3. LLAMADO AL MÓDULO REMOTO DE ALMACENAMIENTO (S3)
module "storage" {
  source        = "github.com/Mantita188/terraform-aws-storage-auy1105-cr.git?ref=v0.1.1"
  environment   = var.environment
  bucket_prefix = "eval2-storage-cr"
}

# ==========================================
# 4. RECURSOS DEL APPLICATION LOAD BALANCER (ALB)
# ==========================================
resource "aws_lb" "external" {
  name               = "${var.environment}-alb-main"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.network.alb_security_group_id]
  subnets            = [module.network.public_subnet_1_id, module.network.public_subnet_2_id]

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "web" {
  name     = "${var.environment}-tg-main"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.network.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "80"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = module.compute.instance_id # Enganche dinámico a la EC2 remota
  port             = 80
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}