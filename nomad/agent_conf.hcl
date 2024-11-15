data_dir  = "/opt/nomad-server/nomad/deploy"

bind_addr = "0.0.0.0" # the default

server {
  enabled          = true
  bootstrap_expect = 1
}

limits {
  http_max_conns_per_client = 400
}


acl{
  enabled = true
}

client {
  enabled       = true
  host_volume "local-volume" {
    path      = "/opt/nomad-server/nomad_volumes/local-volume"
    read_only = false
  }
  
  host_volume "ca-certs" {
    path      = "/etc/ssl/certs"
    read_only = true
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    volumes {
      enabled = true
    }
  }
}

consul {
  address = "0.0.0.0:8500"
}

telemetry {
  collection_interval        = "10s"
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}