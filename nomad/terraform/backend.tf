terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = "~> 2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~>2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
  }
}