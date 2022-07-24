terraform {
  required_providers {
    sakuracloud = {
      source = "sacloud/sakuracloud"
    }
  }
}
provider "sakuracloud" {
  zone = "tk1b"
}

variable "password" {
  type = string
}

data "sakuracloud_archive" "ubuntu" {
  os_type = "ubuntu"
}

data "template_file" "inventory" {
  template = file("./ansible/hosts.tmpl")
  vars = {
    ip_address = "${sakuracloud_server.valheim.ip_address}"
  }
}

resource "null_resource" "inventory" {

  triggers = {
    template = "${data.template_file.inventory.rendered}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ./ansible/hosts"
  }
}

resource "sakuracloud_disk" "valheim" {
  name              = "valheim"
  source_archive_id = "${data.sakuracloud_archive.ubuntu.id}"
}

resource "sakuracloud_server" "valheim" {
  name        = "valheim"
  disks       = [sakuracloud_disk.valheim.id]
  core        = 2
  memory      = 4
  description = "valheim multi server."
  tags        = ["valheim", "staging"]

  network_interface {
    upstream = "shared"
  }

  disk_edit_parameter {
    hostname        = "valheim"
    password        = "${var.password}"
    ssh_key_ids     = ["${sakuracloud_ssh_key.mykey.id}"]
    disable_pw_auth = true
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = "${sakuracloud_server.valheim.ip_address}"
      private_key = file("~/.ssh/id_rsa")
    }
    inline = [
      "echo ${var.password} | sudo -S apt-get install -y python",
      "sudo apt-get update"
    ]
  }
}

resource "sakuracloud_ssh_key" "mykey" {
    name = "valheim"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}