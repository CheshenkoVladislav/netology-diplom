resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.public.id
    ip_address = "192.168.20.254"
    nat        = true
  }
  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
  scheduling_policy {
    preemptible = true
  }
  metadata = {
    user-data = file("${path.module}/cloud_config.yaml")
  }
}


resource "yandex_vpc_route_table" "rt-to-internet" {
  folder_id      = var.folder_id
  name       = "rt-to-internet"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = yandex_compute_instance.nat-instance.network_interface[0].ip_address
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id = yandex_vpc_route_table.rt-to-internet.id
}

resource "yandex_vpc_subnet" "private-central1-b" {
  name           = "private-central1-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.11.0/24"]
  route_table_id = yandex_vpc_route_table.rt-to-internet.id
}

resource "yandex_vpc_subnet" "private-central1-d" {
  name           = "private-central1-d"
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.12.0/24"]
  route_table_id = yandex_vpc_route_table.rt-to-internet.id
}



resource "yandex_vpc_subnet" "private-central-b" {
  name           = "private-central-b"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.21.0/24"]
  route_table_id = yandex_vpc_route_table.rt-to-internet.id
}

resource "yandex_vpc_security_group" "alb-default-sg" {
  name        = "alb-default-sg"
  description = "Security group for Application Load Balancer"
  network_id  = yandex_vpc_network.network.id

  # Правило 1: Входящий HTTP-трафик из интернета
  ingress {
    description    = "Allow all ingress traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Разрешить весь исходящий трафик (egress)
  egress {
    description    = "Allow all egress traffic"
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}