resource "aws_lb" "internet_lb" {
  name               = "internetlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet[1].id]

  enable_deletion_protection = true

}

resource "aws_security_group" "lb_sg" {
  name        = "lb_sg"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.project_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


resource "aws_lb_target_group" "tg" {
  name     = "internet-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.project_vpc.id
}

resource "aws_lb_target_group_attachment" "tg_attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.private_instances[0].id
  port             = 80
}
resource "aws_lb_target_group_attachment" "tg_attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.private_instances[1].id
  port             = 80
}

resource "aws_lb_listener" "internet_lb_listener" {
  load_balancer_arn = aws_lb.internet_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
