data "sakura_archive" "ubuntu" {
  os_type = "ubuntu2404"
}

resource "sakura_disk" "docker_gen_disk" {
  name        = "docker_gen_disk"
  description = "Disk for the docker generation server."

  connector         = "virtio"
  icon_id           = var.ubuntu_icon
  plan              = "ssd"
  size              = 100
  source_archive_id = data.sakura_archive.ubuntu.id
  zone              = var.zone
}

resource "sakura_packet_filter" "minimum_filter" {
  name        = "minimum_filter"
  description = "Minimum packet filter for the docker generation server."
  zone        = var.zone
}

resource "sakura_packet_filter_rules" "rules" {
  packet_filter_id = sakura_packet_filter.minimum_filter.id
  zone             = var.zone

  expression = [
    {
      description      = "Allow SSH access. Limit source IP addresses, if needed."
      destination_port = "22"
      protocol         = "tcp"
      source_network   = "0.0.0.0/0"
    },
    {
      destination_port = "80"
      protocol         = "tcp"
    },
    {
      protocol       = "udp"
      source_port    = "123"
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

resource "sakura_script" "docker_install_script" {
  name    = "docker_install_script"
  class   = "shell"
  content = file("startup-script.sh")
  icon_id = var.ubuntu_icon
}

resource "sakura_ssh_key" "docker_gen_server_sshkey" {
  name        = "docker_gen_server_sshkey"
  description = "SSH key for the docker generation server. Please save it in .ssh/ directory."
  public_key  = file(".ssh/id_rsa.pub")
}

resource "sakura_server" "docker_gen_server" {
  name        = "docker_gen_server"
  description = "Server for the docker image generation."

  core             = 2
  disks            = [sakura_disk.docker_gen_disk.id]
  icon_id          = var.ubuntu_icon
  interface_driver = "virtio"
  memory           = 4
  tags             = ["@keyboard-us"]
  zone             = var.zone

  disk_edit_parameter = {
    hostname            = "ubuntuhost"
    password_wo         = var.os_password
    password_wo_version = 1
    disable_pw_auth     = true

    ssh_key_ids = [sakura_ssh_key.docker_gen_server_sshkey.id]
    script = [{
      id = sakura_script.docker_install_script.id
    }]
  }

  network_interface = [{
    upstream         = "shared"
    packet_filter_id = sakura_packet_filter.minimum_filter.id
  }]
}