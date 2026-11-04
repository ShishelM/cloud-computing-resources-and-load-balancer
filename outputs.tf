# Вспомогательные переменные для безопасного извлечения IP-адреса
locals {
  # 1. Преобразуем set листенеров в list и берем первый элемент [0]
  lb_listener = tolist(yandex_lb_network_load_balancer.lamp-lb.listener)[0]
  
  # 2. Преобразуем внутренний set спецификации адреса в list и берем его адрес
  backend_ip  = tolist(local.lb_listener.external_address_spec)[0].address
}
