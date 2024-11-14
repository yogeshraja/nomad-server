job "promtail" {

  region = "global"
  datacenters = ["dc1"]
  namespace   = "default"
  type        = "system"
  
  
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "promtail" {
    network {
      mode = "bridge"
      port "http" {
        to = 9090
      }
    }

    task "promtail" {
      driver = "docker"
      
      template {
        destination = "local/promtail-config.yaml"
        data = <<-EOT

        server:
          http_listen_port: 
          log_level: 

        positions:
          filename: /tmp/positions.yaml

        clients:
          
        scrape_configs:
        - job_name: journal
          journal:
            max_age: 12h
            json: false
            labels:
              job: systemd-journal
          relabel_configs:
          - source_labels:
            - __journal__systemd_unit
            target_label: systemd_unit
          - source_labels:
            - __journal__hostname
            target_label: nodename
          - source_labels:
            - __journal_syslog_identifier
            target_label: syslog_identifier
        EOT
      }

      config {
        image = "grafana/promtail:latest"
        privileged = true
        args = [
  "-config.file=/etc/promtail/promtail-config.yaml",
  "-log.level=info"
]

        mount {
          type = "bind"
          target = "/etc/promtail/promtail-config.yaml"
          source = "local/promtail-config.yaml"
          readonly = false
          bind_options { propagation = "rshared" }
        }
        
        mount {
          type = "bind"
          target = "/var/log/journal"
          source = "/var/log/journal"
          readonly = true
          bind_options {
            propagation = "rshared"
          }
        }
        mount {
          type = "bind"
          target = "/etc/machine-id"
          source = "/etc/machine-id"
          readonly = false
          bind_options {
            propagation = "rshared"
          }
        }

      }
      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}
