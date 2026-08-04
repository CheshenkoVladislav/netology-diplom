---
  deb:
    hosts:
      ubuntu:
        ansible_connection: ssh
        ansible_host: ${host_ip}
        ansible_port: 22
        ansible_user: adminuser
        ansible_ssh_common_args: '-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
        ansible_ssh_private_key_file: /Users/vladislavcheshenko/Documents/projects/netologia-diplom-project/ci-cd-runner/ansible/prepare_playbook/inventory/ya_cloud
  local:
    hosts:
      localhost:
        ansible_connection: local