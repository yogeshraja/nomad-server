terraform {
  required_version = ">= 1.0"
  required_providers {
    nomad = {
      source  = "hashicorp/nomad"
      version = "~>1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~>3"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2"
    }
  }
}