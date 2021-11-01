resource "aws_lb" "web-nginx" {
  name                       = "nginx-alb-${data.aws_vpc.vpc.id}"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = tolist([data.aws_subnet.public0,data.aws_subnet.public1]).*.id
  security_groups            = [aws_security_group.nginx_instances_access.id]

  tags = {
    "Name" = "nginx-alb-${data.aws_vpc.vpc.id}"
  }
}


resource "aws_lb_listener" "web-nginx" {
  load_balancer_arn = aws_lb.web-nginx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-nginx.arn
  }
}

resource "aws_lb_target_group" "web-nginx" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.vpc.id

  health_check {
    enabled = true
    path    = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
  }

  stickiness {
    type = "lb_cookie"
    cookie_duration = 60
    enabled = true
  }

  tags = {
    "Name" = "nginx-target-group-${data.aws_vpc.vpc.id}"
  }
}

resource "aws_lb_target_group_attachment" "web_server" {
  count            = length(aws_instance.nginx)
  target_group_arn = aws_lb_target_group.web-nginx.id
  target_id        = aws_instance.nginx.*.id[count.index]
  port             = 80
}