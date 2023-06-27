data_dir = "/opt/nomad-server/consul/deploy"
datacenter = "dc1"

server = true
bootstrap_expect = 1

bind_addr = "0.0.0.0"
advertise_addr = "0.0.0.0"

enable_debug = true

client_addr = "0.0.0.0"

retry_join = ["provider=nomad-server tag_key=nomad-server" ]

ui_config {
  enabled = true
}

acl{
  enabled = true
}