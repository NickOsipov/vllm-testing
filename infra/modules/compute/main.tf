resource "yandex_compute_instance" "vllm_instance" {
  name        = var.vm_name
  platform_id = "standard-v3-t4"
  allow_stopping_for_update = true
  zone        = var.zone

  resources {
    gpus   = 1
    cores  = 8
    memory = 32
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = 100
      type     = "network-ssd"
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.vm_username}:${file(var.ssh_public_key)}"
  }

  scheduling_policy {
    preemptible = true
  }
}
