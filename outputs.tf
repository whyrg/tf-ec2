output "ip" {
  description = "The publically accessible IP to connect to your VM"
  value = aws_instance.ec2.public_ip
}
 
