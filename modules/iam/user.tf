# resource "aws_iam_user" "provisioner_user" {
#   name = "${local.name}-provisioner-user"
#   tags = {
#     Name = "${local.name}-provisioner-user"
#   }
# }
#
# resource "aws_iam_user_policy_attachment" "ec2_full_access_user" {
#   user       = aws_iam_user.provisioner_user.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "ssm_core_user" {
#   user       = aws_iam_user.provisioner_user.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }
