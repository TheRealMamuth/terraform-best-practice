# Terraform best practices in digitalocean vpc

Here I describe a problem that occurs when deleting networks in Terraform.

```
Error: Error deleting VPC: DELETE https://api.digitalocean.com/v2/vpcs/873b83d8-83ff-43dc-a6e6-1ba9dbff1714: 409 (request "4ed0adf7-1ca5-47c5-9f69-5d0f030e1411") Can not delete VPC with members
```

```bash
terraform apply -destroy -auto-approve
digitalocean_vpc.main: Refreshing state... [id=873b83d8-83ff-43dc-a6e6-1ba9dbff1714]
digitalocean_droplet.main: Refreshing state... [id=456473350]
digitalocean_project.main: Refreshing state... [id=41494ed7-03f9-4a74-b5a4-fe1b916fa202]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following
symbols:
  - destroy

Terraform will perform the following actions:

  # digitalocean_droplet.main will be destroyed
  - resource "digitalocean_droplet" "main" {
      - backups              = false -> null
      - created_at           = "2024-11-07T20:05:38Z" -> null
      - disk                 = 25 -> null
      - graceful_shutdown    = false -> null
      - id                   = "456473350" -> null
      - image                = "ubuntu-20-04-x64" -> null
      - ipv4_address         = "164.92.172.55" -> null
      - ipv4_address_private = "10.100.0.2" -> null
      - ipv6                 = false -> null
      - locked               = false -> null
      - memory               = 1024 -> null
      - monitoring           = false -> null
      - name                 = "example-digitalocean-droplet" -> null
      - price_hourly         = 0.00893 -> null
      - price_monthly        = 6 -> null
      - private_networking   = true -> null
      - region               = "fra1" -> null
      - resize_disk          = true -> null
      - size                 = "s-1vcpu-1gb" -> null
      - status               = "active" -> null
      - tags                 = [] -> null
      - urn                  = "do:droplet:456473350" -> null
      - vcpus                = 1 -> null
      - volume_ids           = [] -> null
      - vpc_uuid             = "873b83d8-83ff-43dc-a6e6-1ba9dbff1714" -> null
        # (1 unchanged attribute hidden)
    }

  # digitalocean_project.main will be destroyed
  - resource "digitalocean_project" "main" {
      - created_at  = "2024-11-07T20:06:09Z" -> null
      - environment = "Development" -> null
      - id          = "41494ed7-03f9-4a74-b5a4-fe1b916fa202" -> null
      - is_default  = false -> null
      - name        = "example-digitalocean-project" -> null
      - owner_id    = 14150917 -> null
      - owner_uuid  = "8a701089-2cac-4d61-ba6d-b0f7053c6f70" -> null
      - purpose     = "Web Application" -> null
      - resources   = [
          - "do:droplet:456473350",
        ] -> null
      - updated_at  = "2024-11-07T20:06:09Z" -> null
        # (1 unchanged attribute hidden)
    }

  # digitalocean_vpc.main will be destroyed
  - resource "digitalocean_vpc" "main" {
      - created_at  = "2024-11-07 20:05:37 +0000 UTC" -> null
      - default     = false -> null
      - description = "Example VPC" -> null
      - id          = "873b83d8-83ff-43dc-a6e6-1ba9dbff1714" -> null
      - ip_range    = "10.100.0.0/24" -> null
      - name        = "example-digitalocean-vpc" -> null
      - region      = "fra1" -> null
      - urn         = "do:vpc:873b83d8-83ff-43dc-a6e6-1ba9dbff1714" -> null
    }

Plan: 0 to add, 0 to change, 3 to destroy.
digitalocean_project.main: Destroying... [id=41494ed7-03f9-4a74-b5a4-fe1b916fa202]
digitalocean_project.main: Destruction complete after 8s
digitalocean_droplet.main: Destroying... [id=456473350]
digitalocean_droplet.main: Still destroying... [id=456473350, 10s elapsed]
digitalocean_droplet.main: Still destroying... [id=456473350, 20s elapsed]
digitalocean_droplet.main: Destruction complete after 21s
digitalocean_vpc.main: Destroying... [id=873b83d8-83ff-43dc-a6e6-1ba9dbff1714]
╷
│ Error: Error deleting VPC: DELETE https://api.digitalocean.com/v2/vpcs/873b83d8-83ff-43dc-a6e6-1ba9dbff1714: 409 (request "4ed0adf7-1ca5-47c5-9f69-5d0f030e1411") Can not delete VPC with members
│ 
│ 
╵
```

This problem can be solved by adding an additional `null_resource`.

```hcl
resource "null_resource" "main_vpc_droplet_connector" {
  provisioner "local-exec" {
    when = destroy
    command = "sleep 4" # this is a workaround to wait for the VPC to be deleted - 4 seconds should be enough.
  }
}
```


