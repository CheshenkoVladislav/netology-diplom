resource "yandex_container_registry" "diplom-registry" {
  folder_id = var.folder_id
  name      = "netology-diplom-cheshenko"
}

resource "yandex_container_registry_iam_binding" "puller" {
  registry_id = yandex_container_registry.diplom-registry.id
  role        = "container-registry.images.puller"

  members = [
    "system:allUsers",
  ]
}

resource "yandex_container_repository" "diplom-repository" {
  name = "${yandex_container_registry.diplom-registry.id}/diplom-repository"
}