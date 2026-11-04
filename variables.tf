variable "cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
  default     = "b1gj3qbamvs4h8r8keio" # Укажи свой ID
}

variable "folder_id" {
  type        = string
  description = "Yandex Cloud Folder ID"
  default     = "b1g9af9fe1gsnt7r0n36" # Укажи свой ID
}

variable "zone" {
  type        = string
  description = "Дефолтная зона доступности"
  default     = "ru-central1-a"
}

variable "bucket_name" {
  type        = string
  description = "Уникальное имя бакета Object Storage"
  default     = "shishelm-bucket-2026-11"
}

# Единый объект параметров для одиночных ВМ и инстанс-группы
variable "vms_resources" {
  type = map(object({
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  }))
  description = "Ресурсы для вычислительных мощностей"
  default = {
    infrastructure = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 10
    }
    lamp_group = {
      cores         = 2
      memory        = 2
      core_fraction = 20
      disk_size     = 10
    }
  }
}
