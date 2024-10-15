module "app_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.4.0"

  load_balancer_type = "application"
  security_groups    = [ module.vpc_endpoints.security_groups ]
  subnets            = module.vpc.public_subnets
  vpc_id             = module.vpc.vpc_id

  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "TCP"
      description = "Permit incoming HTTP requests from the internet"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Permit all outgoing requests to the internet"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  http_tcp_listeners = [
    {
      # * Setup a listener on port 80 and forward all HTTP
      # * traffic to target_groups[0] defined below which
      # * will eventually point to our "Hello World" app.
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      backend_port     = local.app.container_port
      backend_protocol = "HTTP"
      target_type      = "ip"
    }
  ]
}

output "alb_url" {
  value = "http://${module.app_alb.lb_dns_name}"
}

# resource "aws_lb" "api_lb" {
#   name = "ukol-api-lb"
#   subnets = aws_subnet.public[*].id
#   security_groups = [ aws_security_group.lb.id ]
# }

# resource "aws_lb_target_group" "lb" {
#   name = "ukol-lb-group"
#   port = 3333
#   protocol = "HTTP"
#   vpc_id = aws_vpc.vpc.id
#   target_type = "ip"
#   health_check {
#     path = "/info"
#     matcher = "200,301,302"
#   }
# }

# resource "aws_lb_listener" "lb" {
#   load_balancer_arn = aws_lb.lb.id
#   port = "443"
#   protocol = "HTTPS"
#   certificate_arn = data.aws_acm_certificate.cert.arn

#   default_action {
#     target_group_arn = aws_lb_target_group.lb.id
#     type = "forward"
#   }
# }