output "ec2_public_ip" {
    value = module.myprac-server.instance.public_ip
}