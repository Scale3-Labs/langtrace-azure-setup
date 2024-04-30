locals {
  langtrace_app_service_name = "${var.langtrace_project}-app"

  # Common tags to be assigned to all resources
  common_tags = {
    deployer          = "azd"
    project_name      = var.langtrace_project
    project           = "langtrace"
    created_using     = "terraform"
    langtrace_release = var.github_release_tag
  }
}
