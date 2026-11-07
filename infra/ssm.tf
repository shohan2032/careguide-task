resource "random_password" "app_key" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "app_key" {
  name        = "/${var.project}/app-key"
  description = "AdonisJS APP_KEY for ${var.project}"
  type        = "SecureString"
  value       = random_password.app_key.result

  tags = {
    Name = "${var.project}-app-key"
  }
}
