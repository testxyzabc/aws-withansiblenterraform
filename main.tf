resource "aws_key_pair" "example" {
  key_name   = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "example" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd",
      "sudo service httpd start"
    ]
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > hosts"
  }
  provisioner "local-exec" {
    command = "ansible -i hosts ${self.public_ip} -b -u ec2-user --private-key ~/.ssh/id_rsa -m user -a 'name=demouser state=present uid=1011'"
  }
}


