resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.netology-service-account.id
  description        = "Ключ доступа к стейту"
}

output "tf_state_access" {
    sensitive = true
    value = yandex_iam_service_account_static_access_key.sa-static-key
}