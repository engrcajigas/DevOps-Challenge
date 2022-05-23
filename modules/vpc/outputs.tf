output "vpc" {
  value = aws_vpc.vpc
}

output "private_subnet1" {
  value = aws_subnet.private_subnet1
}

output "private_subnet2" {
  value = aws_subnet.private_subnet2
}

output "public_subnet1" {
  value = aws_subnet.public_subnet1
}

output "public_subnet2" {
  value = aws_subnet.public_subnet2
}