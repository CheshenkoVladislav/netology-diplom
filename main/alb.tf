resource "null_resource" "init-kubectl-config" {
  depends_on = [yandex_kubernetes_cluster.regional_cluster]

  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${yandex_kubernetes_cluster.regional_cluster.id} --external --force"
  }
}

resource "null_resource" "cleanup_gateway_api" {
  provisioner "local-exec" {
    when    = create
    command = <<-EOT
      kubectl delete validatingadmissionpolicy safe-upgrades.gateway.networking.k8s.io --ignore-not-found
      kubectl delete validatingadmissionpolicybinding safe-upgrades.gateway.networking.k8s.io --ignore-not-found
      kubectl delete crd gatewayclasses.gateway.networking.k8s.io --ignore-not-found
      kubectl delete crd gateways.gateway.networking.k8s.io --ignore-not-found
      kubectl delete crd httproutes.gateway.networking.k8s.io --ignore-not-found
      kubectl delete crd referencegrants.gateway.networking.k8s.io --ignore-not-found
      sleep 3
    EOT
  }
}

resource "null_resource" "run_script" {
  depends_on = [yandex_kubernetes_node_group.node_group, null_resource.cleanup_gateway_api]

  provisioner "local-exec" {
    command = <<-EOT
    rm -rf gwin-chart &&
    helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/gwin/charts/gwin-chart \
        --version v1.8.2 \
        --untar &&
    helm install \
        --namespace alb-diplom-cluster \
        --create-namespace \
        --set controller.folderId=${var.folder_id} \
        --set-file controller.ycServiceAccount.secret.value=./prepare.json \
    gwin ./gwin-chart
    EOT
  }
}