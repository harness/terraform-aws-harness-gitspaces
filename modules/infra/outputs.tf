output "vpc_network_id" {
  description = "The ID of the VPC network"
  value       = aws_vpc.vpc_network.id
}

output "iam_role_arn" {
  value = data.aws_iam_instance_profile.provisioner_instance_profile.arn
}

output "aws_security_group_id" {
  value = aws_security_group.gitspace_sg.id
}

output "private_subnet_ids" {
  description = "List of all private subnet IDs with their AZs"
  value = [
    for k in sort(keys(aws_subnet.private_subnet)) : {
      availability_zone = aws_subnet.private_subnet[k].availability_zone
      subnet_id         = aws_subnet.private_subnet[k].id
    }
  ]
}