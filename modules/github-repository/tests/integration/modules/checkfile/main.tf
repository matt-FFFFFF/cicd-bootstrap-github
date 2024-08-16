variable "file_path" {
  type     = string
  nullable = false
}

variable "repository_name" {
  type     = string
  nullable = false
}

variable "branch_name" {
  type     = string
  nullable = false
}

data "github_repository_file" "this" {
  repository = var.repository_name
  file       = var.file_path
  branch     = var.branch_name
}

output "content" {
  value = data.github_repository_file.this.content
}
