locals {
  unix_home = var.username == "root" ? "/root" : "/home/${var.username}"
}

resource "null_resource" "install_helm" {
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }
  provisioner "remote-exec" {
    inline = [
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"
    ]

  }
}

data "template_file" "datadog_values" {
  template = file("${path.module}/templates/datadog-values.yaml")
  vars = {
    datadog_api_key = var.datadog_api_key
    cluster_name    = var.cluster_name
    datadog_site    = var.datadog_site
  }
}

resource "null_resource" "deploy_datadog" {
  depends_on = [
    null_resource.install_helm
  ]
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "file" {
    content     = data.template_file.datadog_values.rendered
    destination = "${local.unix_home}/datadog-values.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "helm repo add datadog https://helm.datadoghq.com",
      "helm repo update",
      "helm install datadog -n datadog --create-namespace -f ${local.unix_home}/datadog-values.yaml datadog/datadog"
    ]
  }
}

resource "null_resource" "deploy_micro_services" {
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "file" {
    content     = file("${path.module}/templates/micro-services.yaml")
    destination = "${local.unix_home}/micro-services.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f ${local.unix_home}/micro-services.yaml"
    ]
  }
}

resource "null_resource" "deploy_descheduler" {
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "file" {
    content     = file("${path.module}/templates/descheduler.yaml")
    destination = "${local.unix_home}/descheduler.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f ${local.unix_home}/descheduler.yaml"
    ]
  }
}

resource "null_resource" "create_external_dns_secret" {
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "file" {
    content     = base64decode(var.cloud_dns_sa)
    destination = "${local.unix_home}/cloud_dns_sa.json"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl create ns external-dns",
      "kubectl create secret generic external-dns --namespace external-dns --from-file ${local.unix_home}/cloud_dns_sa.json"
    ]
  }
}

resource "null_resource" "deploy_external_dns" {
  depends_on = [
    null_resource.install_helm,
    null_resource.create_external_dns_secret
  ]
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "remote-exec" {
    inline = [
      "helm repo add bitnami https://charts.bitnami.com/bitnami",
      "helm repo update",
      "helm install external-dns bitnami/external-dns --create-namespace -n external-dns --set policy=sync --set provider=google --set triggerLoopOnEvent=true --set google.project=${var.gcp_project_id} --set google.serviceAccountSecret=external-dns --set google.serviceAccountSecretKey=cloud_dns_sa.json"
    ]
  }
}

data "template_file" "certs" {
  template = file("${path.module}/templates/certs.yaml")
  vars = {
    fqdn = var.fqdn
  }
}

resource "null_resource" "deploy_certs" {
  depends_on = [
    null_resource.deploy_external_dns
  ]
  connection {
    type        = "ssh"
    user        = var.username
    private_key = file(var.ssh_key_path)
    host        = var.bastion_ip
  }

  provisioner "file" {
    content     = data.template_file.certs.rendered
    destination = "${local.unix_home}/certs.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "kubectl apply -f ${local.unix_home}/certs.yaml"
    ]
  }
}
