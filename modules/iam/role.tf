resource "aws_iam_role" "provisioner" {
  name = "${local.name}-provisioner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${local.name}-provisioner-role"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  role       = aws_iam_role.provisioner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.provisioner.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "provisioner_instance_profile" {
  name = "${local.name}-provisioner-instance-profile"
  role = aws_iam_role.provisioner.name

  tags = {
    Name = "${local.name}-provisioner-instance-profile"
  }
}
