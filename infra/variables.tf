
variable "langtrace_project" {
  description = "Name of the project (should be unique)"
}

variable "region" {
  description = "Location of the resources to be created"
}

variable "docker_image_name" {
  description = "Docker image to be deployed"
  default     = "scale3labs/langtrace-client"
}

variable "github_release_tag" {
  description = "Docker image tag"
  default     = "latest"
}


# Azure PostgreSQL Flexible Server
variable "postgresql_server_sku" {
  description = "The SKU of the PostgreSQL Flexible Server"
  default     = "B_Standard_B1ms"
}

variable "postgres_version" {
  description = "The version of the PostgreSQL Flexible Server"
  default     = "16"
}

variable "postgres_disk_size" {
  description = "The disk size of the PostgreSQL Flexible Server in MB"
  default     = 32768 # 32GB
}

variable "postgres_admin_username" {
  description = "The admin username of the PostgreSQL Flexible Server"
  sensitive   = true
}

variable "postgres_admin_password" {
  description = "The admin password of the PostgreSQL Flexible Server"
  sensitive   = true
}

variable "postgres_port" {
  description = "The port of the PostgreSQL Flexible Server"
  default     = 5432
}

variable "postgres_database_name" {
  description = "The name of the PostgreSQL Flexible Server database"
  default     = "langtracedb"
}

# Azure App Service
variable "app_service_sku" {
  description = "The SKU of the App Service"
  default     = "S2"
}

variable "admin_email" {
  description = "Admin Email"
}

variable "admin_password" {
  description = "Admin Password"
  sensitive   = true
}

variable "clickhouse_host" {
  description = "Clickhouse Host URL eg: https://clickhouse-server.com:<port>"
}

variable "clickhouse_user" {
  description = "Clickhouse User"
}

variable "clickhouse_password" {
  description = "Clickhouse Password"
  sensitive   = true
}

variable "static_env_variables" {
  description = "default environment variables for app service"
  default = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE : "false"
    WEBSITES_PORT : "3000"
    NEXT_PUBLIC_APP_NAME : "Langtrace AI"
    NEXT_PUBLIC_ENVIRONMENT : "production"
    HOSTING_PLATFORM : "Azure"
    NEXTAUTH_SECRET : "difficultsecret"
  }
}
