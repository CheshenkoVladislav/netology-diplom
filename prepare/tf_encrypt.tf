resource "yandex_kms_symmetric_key" "tfstate_key" {
  name              = "tfstate-encryption-key"
  default_algorithm = "AES_256"
  rotation_period   = "8760h" # Автоматическая ротация раз в год
}

resource "yandex_kms_symmetric_key_iam_binding" "access_rights" {
    symmetric_key_id = yandex_kms_symmetric_key.tfstate_key.id
    role = "kms.keys.encrypterDecrypter"

    members = [
        "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
    ]
}