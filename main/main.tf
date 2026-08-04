terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint = "https://storage.yandexcloud.net"
    bucket   = "netologia-cheshenko-tf-state-bucket"
    key      = "prod/terraform.tfstate"
    region   = "ru-central1"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # Необходимая опция Terraform для версии 1.6.1 и старше.
    skip_s3_checksum            = true # Необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}
provider "yandex" {
  zone                     = "ru-central1-a"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = var.service_account_key_path
}