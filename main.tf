terraform {
  required_providers {
    sakura = {
      source = "sacloud/sakura"
      version = "3.4.0"
    }
  }
}

provider "sakura" {
  default_zone = var.zone
  zone = var.zone
  token = var.access_token
  secret = var.access_token_secret
}

resource "sakura_disk" "docker-gen-disk" {
  name              = "docker-gen-disk"
  description       = "Disk for the docker generation server."

  connector         = "virtio"
  icon_id           = var.ubuntu_icon
  plan              = "ssd"
  size              = 100
  source_archive_id = data.sakura_archive.ubuntu.id
  zone              = var.zone
}

resource "sakura_packet_filter" "minimum_filter" {
  name        = "minimum_filter"
  description = "Minimum packet filter for docker-gen-server."
  zone        = var.zone
}

resource "sakura_packet_filter_rules" "rules" {
  packet_filter_id = sakura_packet_filter.minimum_filter.id
  zone             = var.zone

  expression = [
    {
      description       = "Allow SSH access. Limit source IP addresses, if needed."
      destination_port  = "22"
      protocol          = "tcp"
      source_network    = "0.0.0.0/0"
    },
    {
      destination_port  = "80"
      protocol          = "tcp"
    },
    {
      protocol     = "udp"
      source_port  = "123"
      source_network = "0.0.0.0/0"
    },
    {
      protocol         = "udp"
      destination_port = "68"
    },
    {
      protocol = "icmp"
    },
    {
      protocol         = "tcp"
      destination_port = "32768-61000"
    },
    {
      protocol         = "udp"
      destination_port = "32768-61000"
    },
    {
      protocol = "fragment"
    },
    {
      protocol    = "ip"
      allow       = false
      description = "Deny all except above rules."
    }
  ]
}

resource "sakura_script" "docker-install-script" {
  name    = "docker-install-script"
  class   = "shell"
  content = file("startup-script.sh")
  icon_id = var.ubuntu_icon
}

resource "sakura_server" "docker-gen-server" {
  name        = "docker-gen-server"
  description = "Server for the docker image generation."

  core        = 2
  disks       = [sakura_disk.docker-gen-disk.id]
  icon_id     = var.ubuntu_icon
  interface_driver = "virtio"
  memory      = 4
  tags        = ["@keyboard-us"]
  zone        = var.zone

  disk_edit_parameter = {
    hostname = "ubuntuhost"
    password_wo = var.os_password
    password_wo_version = 1
    disable_pw_auth = true

    ssh_key_ids = [sakura_ssh_key.docker-gen-server-sshkey.id]
    script = [{
      id         = sakura_script.docker-install-script.id
    }]
  }

  network_interface = [{
    upstream         = "shared"
    packet_filter_id = sakura_packet_filter.minimum_filter.id
  }]
}

resource "sakura_ssh_key" "docker-gen-server-sshkey" {
  name       = "docker-gen-server-sshkey"
  description = "SSH key for docker-gen-server. Please save it in .ssh/ directory."
  public_key = file(".ssh/id_rsa.pub")
}

data "sakura_archive" "ubuntu" {
  os_type = "ubuntu2404"
}