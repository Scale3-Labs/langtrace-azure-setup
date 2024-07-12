resource "azurerm_resource_group" "langtrace_resource_group" {
  name     = "${var.langtrace_project}-rg"
  location = var.region
  tags     = local.common_tags
}


resource "azurerm_postgresql_flexible_server" "langtrace_postgresql_server" {
  name                = "${var.langtrace_project}-pg"
  resource_group_name = azurerm_resource_group.langtrace_resource_group.name
  location            = var.region

  sku_name                     = var.postgresql_server_sku
  version                      = var.postgres_version
  storage_mb                   = var.postgres_disk_size
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = true
  zone                         = 1

  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password

  tags = local.common_tags
}

resource "azurerm_postgresql_flexible_server_database" "langtrace_postgresql_database" {
  name      = var.postgres_database_name
  server_id = azurerm_postgresql_flexible_server.langtrace_postgresql_server.id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# Allow only the Azure App Service to access the PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server_firewall_rule" "langtrace_postgresql_database_firewall_rule" {
  name             = "${azurerm_postgresql_flexible_server.langtrace_postgresql_server.name}-fw"
  server_id        = azurerm_postgresql_flexible_server.langtrace_postgresql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Azure App Service
resource "azurerm_service_plan" "langtrace_service_plan" {
  name                = "${var.langtrace_project}-sp"
  resource_group_name = azurerm_resource_group.langtrace_resource_group.name
  location            = var.region
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

resource "azurerm_linux_web_app" "langtrace_app_service" {
  name                = local.langtrace_app_service_name
  resource_group_name = azurerm_resource_group.langtrace_resource_group.name
  location            = var.region
  service_plan_id     = azurerm_service_plan.langtrace_service_plan.id

  site_config {
    http2_enabled = true
    application_stack {
      docker_image_name   = "${var.docker_image_name}:${var.github_release_tag}"
      docker_registry_url = "https://docker.io"
    }
  }

  logs {
    detailed_error_messages = false
    failed_request_tracing  = false

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }

  app_settings = merge(var.static_env_variables,
    {
      # Postgres Variables
      POSTGRES_HOST            = azurerm_postgresql_flexible_server.langtrace_postgresql_server.fqdn
      POSTGRES_USER            = var.postgres_admin_username
      POSTGRES_PASSWORD        = var.postgres_admin_password
      POSTGRES_DATABASE        = var.postgres_database_name
      POSTGRES_URL             = "postgres://${var.postgres_admin_username}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.langtrace_postgresql_server.fqdn}:${var.postgres_port}/${var.postgres_database_name}?sslmode=require"
      POSTGRES_PRISMA_URL      = "postgres://${var.postgres_admin_username}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.langtrace_postgresql_server.fqdn}:${var.postgres_port}/${var.postgres_database_name}?sslmode=require&pgbouncer=true&connect_timeout=15"
      POSTGRES_URL_NO_SSL      = "postgres://${var.postgres_admin_username}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.langtrace_postgresql_server.fqdn}:${var.postgres_port}/${var.postgres_database_name}"
      POSTGRES_URL_NON_POOLING = "postgres://${var.postgres_admin_username}:${var.postgres_admin_password}@${azurerm_postgresql_flexible_server.langtrace_postgresql_server.fqdn}:${var.postgres_port}/${var.postgres_database_name}?sslmode=require&pool_max_size=0"

      # Application Variables
      NEXT_PUBLIC_HOST = "https://${local.langtrace_app_service_name}.azurewebsites.net"

      NEXTAUTH_URL          = "https://${local.langtrace_app_service_name}.azurewebsites.net"
      NEXTAUTH_URL_INTERNAL = "https://${local.langtrace_app_service_name}.azurewebsites.net"

      # Clickhouse Variables
      CLICK_HOUSE_HOST          = var.clickhouse_host
      CLICK_HOUSE_USER          = var.clickhouse_user
      CLICK_HOUSE_PASSWORD      = var.clickhouse_password
      CLICK_HOUSE_DATABASE_NAME = "langtrace_traces"

      # Admin login
      ADMIN_EMAIL                    = var.admin_email
      ADMIN_PASSWORD                 = var.admin_password
      NEXT_PUBLIC_ENABLE_ADMIN_LOGIN = true

      # Azure AD Variables
      AZURE_AD_CLIENT_ID     = var.azure_ad_client_id
      AZURE_AD_CLIENT_SECRET = var.azure_ad_client_secret
      AZURE_AD_TENANT_ID     = var.azure_ad_tenant_id
    }
  )

  tags = local.common_tags

  depends_on = [
    azurerm_postgresql_flexible_server_firewall_rule.langtrace_postgresql_database_firewall_rule
  ]
}
