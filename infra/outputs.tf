output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "instance_id" {
  value = aws_instance.app.id
}

output "public_ip" {
  value = aws_eip.app.public_ip
}

output "app_url" {
  value = "http://${aws_eip.app.public_ip}/"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "evaluator_console_url" {
  value = "https://${local.account_id}.signin.aws.amazon.com/console"
}

output "evaluator_username" {
  value = try(aws_iam_user.evaluator[0].name, null)
}

output "evaluator_password" {
  value     = try(aws_iam_user_login_profile.evaluator[0].password, null)
  sensitive = true
}

output "evaluator_access_key_id" {
  value     = try(aws_iam_access_key.evaluator[0].id, null)
  sensitive = true
}

output "evaluator_secret_access_key" {
  value     = try(aws_iam_access_key.evaluator[0].secret, null)
  sensitive = true
}
