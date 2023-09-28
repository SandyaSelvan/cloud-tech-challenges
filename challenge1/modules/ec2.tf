# Public Instances
resource "aws_instance" "public_instances" {
  count                       = 2
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = ["${aws_security_group.sg.id}"]
  subnet_id                   = aws_subnet.public_subnet[count.index].id
  associate_public_ip_address = var.associate_public_ip_address
  tags = {
    Name = "public_instance_${count.index + 1}"
  }
}

# Private Instances
resource "aws_instance" "private_instances" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
  vpc_security_group_ids = ["${aws_security_group.sg.id}"]
  subnet_id              = aws_subnet.private_subnet[count.index].id
  tags = {
    Name = "private_instance_${count.index + 1}"
  }
}

resource "aws_security_group" "sg" {
  vpc_id      = aws_vpc.project_vpc.id
  name        = "security_group"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }
  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg.id]
  }
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }
  tags = {
    Name = "sg"
  }
}

resource "aws_iam_policy" "ssm_policy" {
  name        = "SSMInstanceRolePolicy"
  description = "IAM policy for Session Manager access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:StartSession"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ssm_role" {
  name = "SSMInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "ssm_policy_attachment" {
  name       = "attach_ssm_policy" 
  policy_arn = aws_iam_policy.ssm_policy.arn
  roles      = [aws_iam_role.ssm_role.name]
}

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

