resource "aws_iam_instance_profile" "jenkins-ec2-instance-profile" {
  name = "Jenkins-instance-profile"
  role = aws_iam_role.iam-role.name
}