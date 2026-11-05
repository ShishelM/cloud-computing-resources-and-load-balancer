resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-instance-group"
  folder_id          = var.folder_id
  service_account_id = "aje5o7qhck12gn158ksm" # ID твоего робота pavel

  depends_on = [yandex_storage_object.lamp-image]

  instance_template {
    platform_id = "standard-v1"
    
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = "fd827b91d99psvq5fjit"
        size     = var.vms_resources["lamp_group"].disk_size
      }
    }

    resources {
      cores         = var.vms_resources["lamp_group"].cores
      memory        = var.vms_resources["lamp_group"].memory
      core_fraction = var.vms_resources["lamp_group"].core_fraction
    }

    network_interface {
      network_id = yandex_vpc_network.vpc-network.id
      subnet_ids = [yandex_vpc_subnet.public-subnet.id]
      nat        = false # ПУБЛИЧНЫЕ IP УБРАНЫ ДЛЯ БЕЗОПАСНОСТИ
    }


    metadata = {
      user-data          = templatefile("./cloud-init.tftpl", {
        bucket_image_url = "https://${yandex_storage_bucket.lamp-bucket.bucket_domain_name}/${yandex_storage_object.lamp-image.key}"
      })
      serial-port-enable = 1
    }
  }

  load_balancer {
    target_group_name = "lamp-tg"
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_creating    = 3
    max_expansion   = 1
    max_deleting    = 1
  }

  health_check {
    interval            = 15
    timeout             = 5
    unhealthy_threshold = 5
    healthy_threshold   = 2
    http_options {
      port = 80
      path = "/index.html" # Будет проверять наш сгенерированный файл
    }
  }
}
