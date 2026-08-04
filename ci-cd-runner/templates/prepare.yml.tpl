---
- name: Установка Docker и Docker Compose
  hosts: deb       # Имя вашей группы хостов из инвентаря
  become: true                # Запуск с правами sudo для установки пакетов
  tasks:
    - name: Установка системных зависимостей
      ansible.builtin.apt:
        name:
          - apt-transport-https
          - ca-certificates
          - curl
          - gnupg
          - software-properties-common
        state: present
        update_cache: yes

    - name: Создание директории для GPG ключа Docker
      ansible.builtin.file:
        path: /etc/apt/keyrings
        state: directory
        mode: '0755'

    - name: Скачивание официального GPG ключа Docker
      ansible.builtin.get_url:
        url: https://download.docker.com/linux/ubuntu/gpg
        dest: /etc/apt/keyrings/docker.asc
        mode: '0644'

    - name: Подключение официального репозитория Docker
      ansible.builtin.apt_repository:
        repo: "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable"
        state: present
        filename: docker-ce
        update_cache: yes

    - name: Установка Docker и Docker Compose (v2 плагин)
      ansible.builtin.apt:
        name:
          - docker-ce
          - docker-ce-cli
          - containerd.io
          - docker-buildx-plugin
          - docker-compose-plugin
        state: present
    
    - name: Проверка, что сервис Docker запущен и включен в автозагрузку
      ansible.builtin.service:
        name: docker
        state: started
        enabled: true

    - name: Добавление текущего SSH-пользователя в группу docker (чтобы работать без sudo)
      ansible.builtin.user:
        name: "{{ ansible_user }}"
        groups: docker
        append: yes

- name: Установка Yandex Cloud CLI
  hosts: deb
  become: false
  tasks:
    - name: Установка Yandex Cloud CLI
      ansible.builtin.shell: |
        curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash
      args:
        creates: /usr/bin/yc
    
    - name: Execute yc using updated PATH environment
      ansible.builtin.command: yc --version
      environment:
        PATH: "{{ ansible_env.HOME }}/yandex-cloud/bin:{{ ansible_env.PATH }}"
    
    - name: Перенос ключа сервисного аккаунта в домашнюю директорию
      ansible.builtin.copy:
        src: ../../sa_key.json
        dest: ~/sa_key.json
        mode: '0600'
    
    - name: Установка конфигурации Yandex Cloud CLI
      ansible.builtin.shell: |
        export PATH=$HOME/yandex-cloud/bin:$PATH
        yc config set service-account-key ~/sa_key.json
        yc config set folder-id ${yc_folder_id}
        yc config set cloud-id ${yc_cloud_id}

- name: Установка kubectl
  hosts: deb
  become: false
  tasks:
    - name: Установка kubectl
      become: true
      ansible.builtin.shell: |
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
      args:
        creates: /usr/local/bin/kubectl

    - name: Установка kubectl config
      ansible.builtin.shell: |
        export PATH=$HOME/yandex-cloud/bin:$PATH
        yc managed-kubernetes cluster get-credentials --id cat7t5cng9c5vatqigdr --external
    
    - name: Проверка кластера
      ansible.builtin.shell: |
        kubectl get po
        
- name: Установка nodejs и npm
  hosts: deb
  become: true
  tasks:
    - name: Установка Node.js
      ansible.builtin.apt:
        name:
          - nodejs
        state: present
# - name: Установка Github runner
#   hosts: deb
#   become: false
#   tasks:
#     - name: Установка раннера Github Actions
#       ansible.builtin.shell: |
#         mkdir actions-runner && cd actions-runner
#         curl -o actions-runner-linux-x64-2.336.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.336.0/actions-runner-linux-x64-2.336.0.tar.gz
#         echo "04cf0be1aff4c3ec3554466c39124ca250e3effd8873bb7e8d68535aa9505d5d  actions-runner-linux-x64-2.336.0.tar.gz" | shasum -a 256 -c
#         tar xzf ./actions-runner-linux-x64-2.336.0.tar.gz

#     - name: Настройка и запуск раннера
#       ansible.builtin.shell: |
#         ./actions-runner/config.sh --url https://github.com/CheshenkoVladislav/netology-diplom-nginx --token AINNYOFGCOV5HKXIUY7FKXDKOHCIG
#         ./actions-runner/run.sh