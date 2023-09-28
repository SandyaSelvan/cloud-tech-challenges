resource "aws_db_subnet_group" "dbsubnet" {
  name       = "dbsubnet"
  subnet_ids = ["${aws_subnet.private_subnet[2].id}", "${aws_subnet.private_subnet[3].id}"]
  tags = {
    Name = "DB subnet group"
  }
}

# Database Creation
resource "aws_db_instance" "db_mysql" {
  identifier             = "dbidentifier"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  engine                 = "mysql"
  db_name                = "mydb"
  password               = "Sandya123"
  username               = "masterdb"
  engine_version         = "5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.dbsubnet.name
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
}

resource "aws_security_group" "db" {
  name   = "db-secgroup"
  vpc_id = aws_vpc.project_vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
