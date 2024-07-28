resource "aws_instance" "k8controlplane" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "Kubernetes-control-plane"
    
  }
  vpc_security_group_ids = ["sg-02b6f207e9a3ed6b5"]
  key_name = "lumine"

  # user_data = <<-EOT
  # sudo apt upgrade -y
  # sudo apt install ansible
  # ansible-config init --disabled > ansible.cfg
  # EOT

}
resource "aws_instance" "k8worker" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "Kubernetes-worker"
  }

  vpc_security_group_ids = ["sg-020ae550303f2b3f7"]
  key_name = "lumine"
}

output "controller" {
  value = aws_instance.k8controlplane.public_ip
}

output "worker" {
  value = aws_instance.k8worker.public_ip
}