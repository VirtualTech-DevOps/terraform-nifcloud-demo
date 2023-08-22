terraform {
  required_version = "~> 1.5.5"

  required_providers {
    nifcloud = {
      source  = "nifcloud/nifcloud"
      version = "~> 1.10.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
  }
}
