resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"

  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name : "${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.image_name]

  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "myapp-server" {
  ami                    = data.aws_ami.latest-amazon-linux-image.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  subnet_id              = var.subnet_id
  tags = {
    Name : "${var.env_prefix}-server"
  }
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = "server-key-pair"

  user_data = file("entry_script.sh")

}

resource "aws_key_pair" "ssh-key" {
  key_name   = "aws_key_pair"
  public_key = file(var.public_key)

}
