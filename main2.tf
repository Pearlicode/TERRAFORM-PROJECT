# Instance 1
resource "aws_instance" "Miniproject1" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "Miniproject"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "Miniproject-1"
    source = "terraform"
  }
}
# Instance 2
 resource "aws_instance" "Miniproject2" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "Miniproject"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet2.id
  availability_zone = "us-east-1b"
  tags = {
    Name   = "Miniproject-2"
    source = "terraform"
  }
}
# Instance 3
resource "aws_instance" "Miniproject3" {
  ami             = "ami-00874d747dde814fa"
  instance_type   = "t2.micro"
  key_name        = "Miniproject"
  security_groups = [aws_security_group.Miniproject-security-grp-rule.id]
  subnet_id       = aws_subnet.Miniproject-public-subnet1.id
  availability_zone = "us-east-1a"
  tags = {
    Name   = "Miniproject-3"
    source = "terraform"
  }
}
# File to store IP addresses of the instances
resource "local_file" "Ip_address" {
  filename = "/home/vagrant/TERRAFORM/host-inventory"
  content  = <<EOT
${aws_instance.Miniproject1.public_ip}
${aws_instance.Miniproject2.public_ip}
${aws_instance.Miniproject3.public_ip}
  EOT
}

# Application Load Balancer
resource "aws_lb" "Miniproject-load-balancer" {
  name               = "Miniproject-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Miniproject-load_balancer_sg.id]
  subnets            = [aws_subnet.Miniproject-public-subnet1.id, aws_subnet.Miniproject-public-subnet2.id]
  #Enable_Cross_zone_load_balancing = true
  enable_deletion_protection = false
  depends_on                 = [aws_instance.Miniproject1, aws_instance.Miniproject2, aws_instance.Miniproject3]
}


# Create the target group
resource "aws_lb_target_group" "Miniproject-target-group" {
  name     = "Miniproject-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.Miniproject_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
# Create the listener
resource "aws_lb_listener" "Miniproject-listener" {
  load_balancer_arn = aws_lb.Miniproject-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  }
}
# Create the listener rule
resource "aws_lb_listener_rule" "Miniproject-listener-rule" {
  listener_arn = aws_lb_listener.Miniproject-listener.arn
  priority     = 1
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  }
  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

# Target group to the load balancer
resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment1" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.Miniproject1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment2" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.Miniproject2.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "Miniproject-target-group-attachment3" {
  target_group_arn = aws_lb_target_group.Miniproject-target-group.arn
  target_id        = aws_instance.Miniproject3.id
  port             = 80

  }


