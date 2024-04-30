output "langtrace_url" {
  value = "https://${azurerm_linux_web_app.langtrace_app_service.name}.azurewebsites.net"
}
