locals {
  region                   = "jp-east-4"
  zone                     = "jp-east-41"
  image_name               = "Ubuntu Server 22.04 LTS"
  instance_type            = "small"
  instance_accounting_type = "2" #1:月額課金 2:従量課金
  private_key_name         = "nifcloud_rsa"
  private_key_algorithm    = "RSA" #ニフクラはRSAに対応
  private_key_rsa_bits     = 4096
}

provider "nifcloud" {
  region = local.region
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

resource "nifcloud_instance" "test" {
  instance_id       = "test001"
  availability_zone = local.zone
  image_id          = data.nifcloud_image.ubuntu.id
  key_name          = nifcloud_key_pair.test.key_name
  security_group    = nifcloud_security_group.test.group_name
  instance_type     = local.instance_type
  accounting_type   = local.instance_accounting_type

  network_interface {
    network_id = "net-COMMON_GLOBAL"
  }

  network_interface {
    network_id = "net-COMMON_PRIVATE"
  }
}

data "nifcloud_image" "ubuntu" {
  image_name = local.image_name
}

resource "nifcloud_key_pair" "test" {
  key_name   = "testkey"
  public_key = base64encode(tls_private_key.rsa.public_key_openssh)
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.rsa.private_key_openssh
  filename        = "${path.module}/${local.private_key_name}"
  file_permission = "0600"
}

resource "tls_private_key" "rsa" {
  algorithm = local.private_key_algorithm
  rsa_bits  = local.private_key_rsa_bits
}

output "ssh_command" {
  value = "ssh -i ${path.module}/${local.private_key_name} root@${nifcloud_instance.test.public_ip}"
}

resource "nifcloud_security_group" "test" {
  group_name        = "testfw"
  availability_zone = local.zone

}

resource "nifcloud_security_group_rule" "test" {
  security_group_names = [nifcloud_security_group.test.group_name]
  type                 = "IN"
  from_port            = 0
  to_port              = 65535
  protocol             = "TCP"
  cidr_ip              = "0.0.0.0/0"
}
