# Setup the intial Vault secrets required to enable the K8s auth and 
# dynamic secrets for our applicaton
data "template_file" "provision_secrets" {
  template = "${file("${path.module}/scripts/provision_secrets.sh")}"

  vars {
    auth_enabled              = "${var.authserver_enabled}"
    redis_key                 = "${var.authserver_enabled == true ? azurerm_redis_cache.emojify_cache.primary_access_key : "nil"}"
    redis_server              = "${var.authserver_enabled == true ? azurerm_redis_cache.emojify_cache.hostname : "nil"}"
    db_server                 = "${var.authserver_enabled == true ? azurerm_postgresql_server.emojify_db.fqdn : "nil"}"
    db_database               = "keratin"
    db_username               = "${var.authserver_enabled == true ? azurerm_postgresql_server.emojify_db.administrator_login : "nil"}"
    db_password               = "${var.authserver_enabled == true ? azurerm_postgresql_server.emojify_db.administrator_login_password : "nil"}"
    github_auth_client_id     = "${var.github_auth_client_id}"
    github_auth_client_secret = "${var.github_auth_client_secret}"
  }
}

resource "null_resource" "provision_secrets" {
  triggers {
    private_key_id = "${data.terraform_remote_state.core.jumpbox_key}"
    firewall_rules = "${azurerm_postgresql_firewall_rule.emojify_db.id}"
  }

  connection {
    host        = "${data.terraform_remote_state.core.jumpbox_host}"
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${data.terraform_remote_state.core.jumpbox_key}"
    agent       = false
  }

  provisioner "file" {
    content     = "${data.template_file.provision_secrets.rendered}"
    destination = "/tmp/provision_secrets.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision_secrets.sh",
      "sudo /tmp/provision_secrets.sh",
    ]
  }
}
