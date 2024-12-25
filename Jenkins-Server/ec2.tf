
resource "aws_instance" "ec2" {
  ami                    = data.aws_ami.ubuntu.image_id
  instance_type          = "t3.large"
  key_name               = var.key-name
  subnet_id              = data.aws_subnets.public_subnets.ids[0]
  vpc_security_group_ids = [aws_security_group.jenkins_ec2_security.id]
  iam_instance_profile   = aws_iam_instance_profile.jenkins-ec2-instance-profile.name
  root_block_device {
    volume_size = 50
  }
  user_data = templatefile("./tools-install.sh", {})

  tags = {
    Name = var.instance-name
  }
}