data_dir = "/opt/nomad-server/consul/deploy"
server = true
bootstrap_expect = 1

datacenter = "dc1"
enable_debug = true

client_addr = "0.0.0.0"

retry_join = ["provider=nomad-server tag_key=nomad-server" ]

ui_config {
  enabled = true
}

acl{
  enabled = true
}

addresses {
  http = "0.0.0.0"
}