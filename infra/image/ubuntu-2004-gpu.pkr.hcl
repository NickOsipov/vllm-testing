packer {
  required_plugins {
    yandex = {
      version = "~> 1"
      source  = "github.com/hashicorp/yandex"
    }
  }
}

variable "folder_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "token" {
  type = string
}

variable "zone" {
  type    = string
  default = "ru-central1-a"
}

source "yandex" "ubuntu" {
  token        = var.token
  folder_id    = var.folder_id
  subnet_id    = var.subnet_id
  zone         = var.zone

  source_image_family = "ubuntu-2004-lts"
  ssh_username = "ubuntu"
  use_ipv4_nat = true
  preemptible = true

  platform_id  = "gpu-standard-v1"
  instance_cores = 8
  instance_gpus  = 1
  instance_mem_gb = 96

  disk_type     = "network-ssd"
  disk_size_gb  = 100

  image_name        = "ubuntu-nvidia-docker-${formatdate("YYYY-MM-DD-hh-mm", timestamp())}"
  image_family      = "ubuntu-nvidia-docker"
  image_description = "Ubuntu image with NVIDIA drivers and Docker"
}

build {
  sources = ["source.yandex.ubuntu"]

  # Обновление системы и установка базовых пакетов
  provisioner "shell" {
    inline = [
      "sleep 30",
      "sudo apt-get update",
      "sudo apt-get install -y linux-headers-$(uname -r)",
      "sudo apt-get install -y build-essential",
      "sudo apt-get install -y wget",
    ]
  }

  # Установка драйверов NVIDIA
  provisioner "shell" {
    inline = [
      # Добавление репозитория NVIDIA
      "sudo apt-get install -y software-properties-common",
      "sudo add-apt-repository -y ppa:graphics-drivers/ppa",
      "sudo apt-get update",
      
      # Установка драйвера NVIDIA
      "sudo apt-get install -y nvidia-driver-560",
      
      # Установка CUDA Toolkit
      "wget https://developer.download.nvidia.com/compute/cuda/12.6.3/local_installers/cuda_12.6.3_560.35.05_linux.run",
      "sudo sh cuda_12.6.3_560.35.05_linux.run --silent --toolkit",
      "rm cuda_12.6.3_560.35.05_linux.run",
      
      # Добавление CUDA в PATH
      "echo 'export PATH=/usr/local/cuda-12.6/bin:$PATH' | sudo tee -a /etc/profile.d/cuda.sh",
      "echo 'export LD_LIBRARY_PATH=/usr/local/cuda-12.6/lib64:$LD_LIBRARY_PATH' | sudo tee -a /etc/profile.d/cuda.sh",
    ]
  }

  # Установка Docker
  provisioner "shell" {
    inline = [
      # Установка зависимостей
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      
      # Добавление официального GPG ключа Docker
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      
      # Добавление репозитория Docker
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      
      # Установка Docker
      "sudo apt-get update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
      
      # Добавление пользователя в группу docker
      "sudo usermod -aG docker ubuntu",
    ]
  }

  # Установка NVIDIA Container Toolkit
  provisioner "shell" {
    inline = [
      # Настройка репозитория NVIDIA Container Toolkit
      "distribution=$(. /etc/os-release;echo $ID$VERSION_ID)",
      "curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -",
      "curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list",
      
      # Установка NVIDIA Container Toolkit
      "sudo apt-get update",
      "sudo apt-get install -y nvidia-container-toolkit",
      
      # Настройка Docker для использования NVIDIA Container Runtime
      "sudo nvidia-ctk runtime configure --runtime=docker",
      
      # Перезапуск Docker
      "sudo systemctl restart docker",
    ]
  }
}