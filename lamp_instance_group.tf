resource "yandex_compute_instance_group" "lamp-group" {
  name               = "lamp-instance-group"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.sa-bucket.id

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
      nat        = true
    }

    metadata = {
      user-data          = file("./cloud-init.yml")
      serial-port-enable = 1
      bucket_img_url     = "https://${yandex_storage_bucket.lamp-bucket.bucket_domain_name}/${yandex_storage_object.lamp-image.key}"
    }
  }

  # Обязательный блок для создания связи с Network Load Balancer!
  load_balancer {
    target_group_name        = "lamp-tg"
    target_group_description = "Целевая группа для сетевого балансировщика"
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
    max_creating    = 1
    max_expansion   = 1
    max_deleting    = 1
  }

  health_check {
    interval            = 10
    timeout             = 2
    unhealthy_threshold = 3
    healthy_threshold   = 2
    http_options {
      port = 80
      path = "/index.html"
    }
  }
}
