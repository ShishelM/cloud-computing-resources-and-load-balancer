# Виртуальная сеть (VPC)
resource "yandex_vpc_network" "vpc-network" {
  name = "vpc-network"
}

# Публичная подсеть (Public Subnet)
# Сюда смотрят: public-vm, nat-instance и новая инстанс-группа lamp-group
resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Приватная подсеть (Private Subnet)
# Использует таблицу маршрутизации для выхода в интернет через NAT
resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.vpc-network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = yandex_vpc_route_table.private-route-table.id
}

# Таблица маршрутизации для приватной сети
# Перенаправляет весь трафик (0.0.0.0/0) на внутренний IP вашего NAT-инстанса
resource "yandex_vpc_route_table" "private-route-table" {
  name       = "private-route-table"
  network_id = yandex_vpc_network.vpc-network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}
