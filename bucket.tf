# Сервисный аккаунт для управления Object Storage и Instance Group
resource "yandex_iam_service_account" "sa-bucket" {
  name        = "sa-bucket-manager"
  description = "Сервисный аккаунт для работы с Object Storage и Instance Group"
}

# Назначение роли editor для создания ВМ и бакета внутри каталога
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-bucket.id}"
}

# Создание статического ключа доступа для S3
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa-bucket.id
  description        = "Статический ключ для S3"
}

# Создание бакета Object Storage (без параметра acl)
resource "yandex_storage_bucket" "lamp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name
}

# Отдельное управление правами доступа (грант на публичное чтение)
resource "yandex_storage_bucket_grant" "lamp-bucket-grant" {
  bucket     = yandex_storage_bucket.lamp-bucket.id
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key

  grant {
    type        = "Group"
    permissions = ["READ"]
    uri         = "http://amazonaws.com" # Разрешает чтение всем пользователям интернета
  }
}


# Загрузка файла картинки в бакет
resource "yandex_storage_object" "lamp-image" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.lamp-bucket.id
  key        = "screenshot.png"
  source     = "${path.module}/img/screenshot.png"
  acl        = "public-read"
}
