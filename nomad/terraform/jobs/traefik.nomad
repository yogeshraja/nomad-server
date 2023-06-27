job "traefik" {
  datacenters = ["dc1"]
  type        = "system"

  group "traefik" {
    network {
      port "web" {
        static = 80
      }
      port "https" {
        static = 443
      }
      port "admin" {
        static = 8083
      }
    }

    service {
      name = "traefik"
      port = "web"

      check {
        type     = "http"
        path     = "/ping"
        port     = "web"
        interval = "10s"
        timeout  = "2s"
      }
    }
    volume "ca-certs" {
      type      = "host"
      read_only = true
      source    = "ca-certs"
    }

    task "traefik" {
      driver = "docker"

      volume_mount {
        volume      = "ca-certs"
        destination = "/etc/ssl/certs"
      }

      config {
        image        = "traefik:v3.1"
        network_mode = "host"
        args = [		  
		    "--api.insecure=true"
        ]
        ports = ["web"]

        volumes = [
          "local/traefik.yaml:/etc/traefik/traefik.yaml",
          "local/routers.yaml:/etc/traefik/providers/routers.yaml",
        ]
      }

      template {
        data = <<EOF
entryPoints:
  http:
    address: ":80"
  https:
    address: ":443"
    http:
      tls: true
  tcp:
    address: ":444"
  admin:
    address: ":8081"
    http:
      tls: true
  metrics:
    address: ":8082"
log:
  level: debug
metrics:
  prometheus:
    addEntryPointsLabels: true
    addRoutersLabels: true
    addServicesLabels: true
    entrypoint: metrics
api:
  dashboard: true
  insecure: true
ping:
  entryPoint: "http"
providers:
  file:
    directory: "/etc/traefik/providers"
    watch: true
  consulCatalog:
    refreshInterval: 10s
    connectAware: true
    connectByDefault: false
    defaultRule: "Host(`{{ .Name }}.localhost`)"
    serviceName: "traefik"
    prefix: "traefik"
    exposedByDefault: false
    watch: true
    endpoint:
      address: "127.0.0.1:8500"
      scheme: "http"
EOF

        destination = "local/traefik.yaml"
      }

      template{
        data = <<EOF
http:
  routers:
    nomad:
      rule: Host(`nomad.localhost`)
      entrypoints:
        - http
        - https
      service: nomad
    consul:
      rule: Host(`consul.localhost`)
      entrypoints:
        - http
        - https
      service: consul
    traefik:
      rule: Host(`traefik.localhost`)
      entrypoints:
        - http
        - https
      service: traefik
  services:
    nomad:
      loadbalancer:
        servers:
          - url: http://127.0.0.1:4646
    consul:
      loadbalancer:
        servers:
          - url: http://127.0.0.1:8500
    traefik:
      loadbalancer:
        servers:
          - url: http://127.0.0.1:8080
EOF
        destination="local/routers.yaml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}