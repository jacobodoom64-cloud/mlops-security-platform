variable "image_tag" {
  description = "Container image tag to deploy. Set to the git commit SHA by the pipeline so Terraform detects a real change on every build."
  type        = string
  default     = "latest"
}
