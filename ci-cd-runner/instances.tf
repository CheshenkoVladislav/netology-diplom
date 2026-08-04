resource "yandex_vpc_network" "network" {
  name = "default"
}

resource "yandex_vpc_subnet" "agents" {
  name           = "agents"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_compute_instance" "agent-instance" {
  name        = "agent-instance"
  platform_id = "standard-v3"
  boot_disk {
    initialize_params {
      image_id = "fd8ulqth5qf5suqiecli"
    }
  }
  network_interface {
    subnet_id  = yandex_vpc_subnet.agents.id
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

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

resource "local_file" "ansible-inventory" {
  filename = "ansible/prepare_playbook/inventory/agent.yml"
  content  = templatefile("${path.module}/templates/agent.yml.tpl", {
    host_ip = yandex_compute_instance.agent-instance.network_interface.0.nat_ip_address
    private_key_path = var.private_key_path
  })
}

resource "local_file" "ansible-playbook" {
  filename = "ansible/prepare_playbook/prepare.yml"
  content  = templatefile(abspath("${path.module}/templates/prepare.yml.tpl"), {
    yc_folder_id                = var.folder_id
    yc_cloud_id                 = var.cloud_id
  })
}

resource "null_resource" "ansible-provisioner" {
  depends_on = [local_file.ansible-inventory, local_file.ansible-playbook, yandex_compute_instance.agent-instance]

  provisioner "local-exec" {
    command = <<-EOT
    ansible-playbook -i ansible/prepare_playbook/inventory/agent.yml ansible/prepare_playbook/prepare.yml
    EOT
  }
}
