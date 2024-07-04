job "grafana" {
  region = "global"
  datacenters = ["dc1"]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = 3000
      }
    }

    service {
      name = "grafana"
      port = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.grafana.entrypoints=http",
        "traefik.http.routers.grafana.rule=Host(`grafana.localhost`)",
      ]
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 512
      }

      env {
        GF_LOG_LEVEL = "DEBUG"
        GF_LOG_MODE = "console"
        GF_SERVER_HTTP_PORT = "${NOMAD_PORT_http}"
        GF_PATHS_PROVISIONING = "/local/grafana/provisioning"
        GF_PATHS_CONFIG = "/local/grafana/grafana.ini"
      }

      artifact {
        source      = "https://grafana.com/api/dashboards/1860/revisions/26/download"
        destination = "local/grafana/provisioning/dashboards/linux/linux-node-exporter.json"
        mode = "file"

      }

      template {
        data = <<EOF

EOF
        destination = "/local/grafana/grafana.ini"
      }
      template {
        data = <<EOF
apiVersion: 1

providers:
  - name: dashboards
    type: file
    updateIntervalSeconds: 30
    options:
      foldersFromFilesStructure: true
      path: /local/grafana/provisioning/dashboards

EOF
        destination = "/local/grafana/provisioning/dashboards/dashboards.yaml"
      }
      template {
        data = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus.service.{{ env "NOMAD_DC" }}.consul:9090
    jsonData:
      exemplarTraceIdDestinations:
        - name: traceID
          datasourceUid: tempo
  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo.service.{{ env "NOMAD_DC" }}.consul:3200
    uid: tempo
  - name: Loki
    type: loki
    access: proxy
    url: http://loki.service.{{ env "NOMAD_DC" }}.consul:3100
    jsonData:
      derivedFields:
        - datasourceUid: tempo
          matcherRegex: (?:traceID|trace_id)=(\w+)
          name: TraceID
          url: $${__value.raw}

EOF
        destination = "/local/grafana/provisioning/datasources/datasources.yaml"
      }
    }
  }
}
