variable "yc_config" {
  type = object({
    zone      = string
    folder_id = string
    token     = string
    cloud_id  = string
  })
  description = "Yandex Cloud configuration"
}

variable "image_id" {
  type        = string
  description = "Image ID for the compute instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the compute instance"
}

variable "vm_name" {
  type        = string
  description = "Name for the compute instance"
  default     = "vllm-instance"
}

variable "vm_username" {
  type        = string
  description = "Username for SSH access"
  default     = "ubuntu"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key path"
}
