job "flask-hello" {
  datacenters = ["dc1"]
  type = "service"

  group "web" {
    task "flask" {
      driver = "docker"

      config {
        image = "pallets/flask:2.2.5"
        port_map {
          http = 5000
        }
      }

      resources {
        cpu    = 500
        memory = 256
        network {
          mbits = 10
          port "http" {}
        }
      }

      service {
        name = "flask-hello"
        port = "http"
        tags = ["urlprefix-/"]
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
