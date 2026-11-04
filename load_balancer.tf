resource "yandex_lb_network_load_balancer" "lamp-lb" {
  name = "lamp-network-load-balancer"

  listener {
    name = "http-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    # Снова используем официальный синтаксис, теперь он отработает корректно
    target_group_id = yandex_compute_instance_group.lamp-group.load_balancer[0].target_group_id

    healthcheck {
      name                = "http"
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
}
