data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "K8s-Master"
  }
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "K8s-Worker"
  }
}