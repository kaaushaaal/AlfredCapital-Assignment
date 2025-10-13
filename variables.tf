variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  default = "centralindia"
}

variable "resource_group_name" {
  default = "nomad-demo"
}

variable "ssh_username" {
  default = "kaushalazure"
}

variable "ssh_public_key_path" {
  default = "C:/Users/kaush/azure.pub"
}

variable "nomad_client_count" {
  default = 2
}

variable "vm_size" {
  default = "Standard_B1s"
}

# optional: you can remove allowed_ip if using Bastion only
# variable "allowed_ip" {
#   default = "49.36.233.194/32"
# }
