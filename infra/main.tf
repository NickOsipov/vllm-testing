module "compute" {
  source         = "./modules/compute"
  config         = var.yc_config
  image_id       = var.image_id
  ssh_public_key = var.ssh_public_key
  subnet_id      = var.subnet_id
}
