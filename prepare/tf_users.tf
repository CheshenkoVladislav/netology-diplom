resource "yandex_iam_service_account" "netology-service-account" {
  name      = "netology-service"
  folder_id = var.folder_id
}

resource "yandex_iam_service_account_iam_binding" "editor-account-iam" {
  service_account_id = yandex_iam_service_account.netology-service-account.id
  role               = "editor"

  members = [
    "userAccount:${var.yc_account_id}",
  ]
}

output "service_account_info" {
  value = yandex_iam_service_account.netology-service-account
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-admin" {
  folder_id = var.folder_id
  role      = "k8s.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-cluster-admin" {
  folder_id = var.folder_id
  role      = "k8s.cluster-api.cluster-admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-cluster-admin-full" {
  folder_id = var.folder_id
  role      = "k8s.cluster-api.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

# Роль для создания виртуальных машин (нод)
resource "yandex_resourcemanager_folder_iam_binding" "compute-editor" {
  folder_id = var.folder_id
  role      = "compute.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

# Роль для работы с сетями
resource "yandex_resourcemanager_folder_iam_binding" "vpc-admin" {
  folder_id = var.folder_id
  role      = "vpc.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "kms-editor" {
  folder_id = var.folder_id
  role      = "kms.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

# Роль для работы с образами дисков
resource "yandex_resourcemanager_folder_iam_binding" "image-user" {
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "container-registry-admin" {
  folder_id = var.folder_id
  role      = "container-registry.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "alb_editor" {
  folder_id = var.folder_id
  role      = "alb.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "certificate-manager_certificates_downloader" {
  folder_id = var.folder_id
  role      = "certificate-manager.certificates.downloader"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "compute_viewer" {
  folder_id = var.folder_id
  role      = "compute.viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "smart-web-security_editor" {
  folder_id = var.folder_id
  role      = "smart-web-security.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-service-account.id}"
  ]
}

# resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
#   service_account_id = yandex_iam_service_account.netology-service-account.id
#   description        = "static access key for object storage"
#   pgp_key            = "keybase:netology-service"
# }

# output "service_account_token" {
#   value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#   sensitive = true
# }