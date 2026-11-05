# Генерируем статический S3-ключ прямо для твоего текущего робота pavel
# (так как Terraform запущен от его имени, он имеет право выпустить ключ сам себе)
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "aje5o7qhck12gn158ksm" # Строго ID твоего робота pavel со скриншота
  description        = "Статический ключ для Object Storage"
}

# Создаем бакет от одного аккаунта
resource "yandex_storage_bucket" "lamp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name

  # Открываем бакет всему интернету для чтения картинок
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

# Загружаем картинку
resource "yandex_storage_object" "lamp-image" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.lamp-bucket.id
  key        = "screenshot.png"
  source     = "${path.module}/img/screenshot.png"
}
