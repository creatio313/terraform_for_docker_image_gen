variable "access_token" {
  type        = string
  description = "Access token of the project."
}
variable "access_token_secret" {
  type        = string
  description = "Access token secret of the project"
  sensitive   = true
}
variable "os_password" {
  type        = string
  description = "OS password of the server."
  sensitive   = true
}
variable "ubuntu_icon" {
  type        = string
  description = "ID of the ubuntu icon."
  default     = "112901627751"
}
variable "zone" {
  type        = string
  description = "Zone to build resources."
  default     = "is1c"
}