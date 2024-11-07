terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

variable "do_token" {
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  default     = "fra1"
}

resource "digitalocean_project" "main" {
  name = "example-digitalocean-project"
  environment = "development"
  resources = [ digitalocean_droplet.main.urn]
}

resource "digitalocean_vpc" "main" {
  name        = "example-digitalocean-vpc"
  region      = var.region
  description = "Example VPC"
  ip_range    = "10.100.0.0/24"
}

resource "null_resource" "main_vpc_droplet_connector" {
  provisioner "local-exec" {
    when = destroy
    command = "sleep 4" # this is a workaround to wait for the VPC to be deleted - 4 seconds should be enough.
  }

  depends_on = [ digitalocean_vpc.main ]
}

resource "digitalocean_droplet" "main" {
  name     = "example-digitalocean-droplet"
  region   = var.region
  size     = "s-1vcpu-1gb"
  image    = "ubuntu-20-04-x64"
  vpc_uuid = digitalocean_vpc.main.id

  depends_on = [ null_resource.main_vpc_droplet_connector ]
}
