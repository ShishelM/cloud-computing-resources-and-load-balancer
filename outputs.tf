locals {
  # 1. Преобразуем сет листенеров в список и берем первый листенер [0]
  lb_listener = tolist(yandex_lb_network_load_balancer.lamp-lb.listener)[0]
  
  # 2. Преобразуем внутренний сет адресов в список и берем первый адрес, у которого уже есть свойство .address
  backend_ip  = tolist(local.lb_listener.external_address_spec)[0].address
}

output "homework_report" {
  description = "Готовый отчет для проверки домашнего задания"
  value       = <<EOF

====================================================================
           РЕЗУЛЬТАТЫ РАЗВЕРТЫВАНИЯ ДОМАШНЕГО ЗАДАНИЯ 15.2
====================================================================

1. Сетевой балансировщик (Network Load Balancer) успешно создан.
   Открыть веб-страницу группы LAMP в браузере:
   http://${local.backend_ip}/

2. Прямая ссылка на файл в Object Storage бакете:
   https://${yandex_storage_bucket.lamp-bucket.bucket_domain_name}/${yandex_storage_object.lamp-image.key}

====================================================================
EOF
}
