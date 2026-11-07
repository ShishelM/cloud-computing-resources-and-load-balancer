# 1. Генерируем статический S3-ключ для робота pavel
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "aje5o7qhck12gn158ksm" # ID твоего робота pavel
  description        = "Статический ключ для Object Storage"
}

# 2. Создаем симметричный ключ KMS для шифрования бакета
resource "yandex_kms_symmetric_key" "bucket_key" {
  name              = "bucket-kms-key"
  description       = "KMS key for Object Storage bucket encryption"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # Период ротации — 1 год
}

# 3. Создаем защищенный бакет Object Storage с KMS шифрованием
resource "yandex_storage_bucket" "lamp-bucket" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = var.bucket_name

  # Оставляем стандартные флаги безопасности (анонимный доступ к зашифрованному бакету не нужен)
  anonymous_access_flags {
    read        = false
    list        = false
    config_read = false
  }

  # Блок шифрования на стороне сервера (SSE-KMS)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

# 4. Загружаем проверочный объект в зашифрованный бакет
resource "yandex_storage_object" "lamp-image" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = yandex_storage_bucket.lamp-bucket.id
  key        = "screenshot.png"
  source     = "${path.module}/img/screenshot.png"
}
