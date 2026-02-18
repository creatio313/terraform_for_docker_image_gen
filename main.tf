terraform {
  required_providers {
    sakura = {
      source = "sacloud/sakura"
      version = "3.4.0"
    }
  }
}

provider "sakura" {
  # Configuration options
  default_zone = "${var.zone}"
  zone = "${var.zone}"
  token = "${var.access_token}"
  secret = "${var.access_token_secret}"
}

resource "sakura_server" "docker-gen-server" {
  name        = "docker-gen-server"
  description = "Server for the docker image generation."

  core        = 2
  disks       = [sakura_disk.docker-gen-disk.id]
  icon_id     = "${var.ubuntu_icon}"
  interface_driver = "virtio"
  memory      = 4
  tags        = ["@keyboard-us"]
  zone        = "${var.zone}"

  disk_edit_parameter = {
    hostname = "ubuntuhost"
    password_wo = "${var.os_password}"
    password_wo_version = 1
    disable_pw_auth = true

    ssh_key_ids = ["${var.ssh_key_id}"]
    script = [{
      id         = "${var.docker_install_script}"
    }]
  }

  network_interface = [{
    upstream         = "shared"
    packet_filter_id = "${var.packet_filter_id}"
  }]
}

data "sakura_archive" "ubuntu" {
  os_type = "ubuntu2404"
}

resource "sakura_disk" "docker-gen-disk" {
  name              = "docker-gen-disk"
  description       = "Disk for the docker generation server."

  connector         = "virtio"
  icon_id           = "${var.ubuntu_icon}"
  plan              = "ssd"
  size              = 100
  source_archive_id = data.sakura_archive.ubuntu.id
  zone              = "${var.zone}"
}