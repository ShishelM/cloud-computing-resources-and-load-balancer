# NAT-инстанс в публичной сети
resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores         = var.vms_resources["infrastructure"].cores
    memory        = var.vms_resources["infrastructure"].memory
    core_fraction = var.vms_resources["infrastructure"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size     = var.vms_resources["infrastructure"].disk_size
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.public-subnet.id
    ip_address = "192.168.10.254"
    nat        = true
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}

# Тестовая ВМ в публичной сети
resource "yandex_compute_instance" "public-vm" {
  name        = "public-vm"
  platform_id = "standard-v1"
  zone        = var.zone

  resources {
    cores         = var.vms_resources["infrastructure"].cores
    memory        = var.vms_resources["infrastructure"].memory
    core_fraction = var.vms_resources["infrastructure"].core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = "fd827b91d99psvq5fjit"
      size     = var.vms_resources["infrastructure"].disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
  }

  metadata = {
    user-data          = file("./cloud-init.yml")
    serial-port-enable = 1
  }
}
