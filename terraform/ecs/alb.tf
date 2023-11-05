resource "aws_lb" "app_lb" {
  name               = "${var.cluster_name}-lb"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.cluster_name}-tg"
  port     = 80
  protocol = "TCP"
  target_type = "ip"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_security_group" "sg" {
  name        = "${var.cluster_name}-sg"
  description = "Allow traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
