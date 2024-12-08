variable "image_id" {
  type        = string
  description = "Image ID for the compute instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the compute instance"
}

variable "config" {
  type        = object({
    zone      = string
    folder_id = string
    token     = string
    cloud_id  = string
  })
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key path"
}
