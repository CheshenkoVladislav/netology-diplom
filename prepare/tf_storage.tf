resource "yandex_storage_bucket" "tf-state-bucket" {
  bucket = "netologia-cheshenko-tf-state-bucket"
  max_size = 104857600
  folder_id = var.folder_id

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.tfstate_key.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "yandex_storage_bucket_iam_binding" "bucket_editor" {
  bucket = yandex_storage_bucket.tf-state-bucket.bucket
  role   = "storage.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}
