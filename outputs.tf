output "nomad_server_public_ip" {
  value = azurerm_public_ip.server_pip.ip_address
}

output "ssh_command" {
  value = "ssh -L 4646:localhost:4646 ${var.ssh_username}@${azurerm_public_ip.server_pip.ip_address}"
}

output "nomad_ui_url" {
  value = "http://localhost:4646 after SSH tunnel"
}
