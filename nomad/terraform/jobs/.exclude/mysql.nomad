job "dossier" {
  datacenters = ["dc1"]
  type = "service"


  group "mysql" {
    
    count = 1

    restart {
      attempts = 5
      interval = "5m"
      delay    = "25s"
      mode     = "fail"
    }

    volume "ca-certs" {
      type      = "host"
      read_only = true
      source    = "ca-certs"
    }


    task "Start-MySQL-Server" {
      driver = "docker"

      volume_mount {
        volume      = "ca-certs"
        destination = "/etc/ssl/certs"
      }

      config {
        image = "percona:8.0"

        ports = ["mysql"]

        mount {
          type   = "bind"
          source = "local/tmp"
          target = "/docker-entrypoint-initdb.d"
        }
      }

      env {
          MYSQL_ROOT_PASSWORD =  "test@123"
          MYSQL_DATABASE = "test"
          MYSQL_USER = "admin"
          MYSQL_PASSWORD = "admin@123"
      }

      resources {
        cpu    = 512
        memory = 1024
        memory_max = 1024
      }

      template{
        data        = <<EOF
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+05:30";

--
-- Database: `build_dashboard`
--
CREATE DATABASE IF NOT EXISTS `build_dashboard` DEFAULT CHARACTER SET latin1 COLLATE latin1_swedish_ci;
USE `build_dashboard`;

-- --------------------------------------------------------

--
-- Table structure for table `build_request`
--

CREATE TABLE IF NOT EXISTS `build_request` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `Build Name` varchar(30) NOT NULL,
  `Build JIRA` varchar(30) NOT NULL,
  `Branch Name` text NOT NULL,
  `Firmware Version` varchar(30) NOT NULL,
  `Test Phase` varchar(30) NOT NULL,
  `Package Locations` text NOT NULL,
  `Smoke Test Status` varchar(30) NOT NULL DEFAULT 'N/A',
  `Smoke Test Link` varchar(250) NOT NULL DEFAULT 'N/A',
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

COMMIT;
EOF
        destination = "local/tmp/mysql-init.sql"
      }

      service {
        name = "mysql-build-dashboard"
        port = "mysql"
        tags = [
            "traefik.enable=true",
            "traefik.tcp.routers.mysql-build-dashboard.tls=true",
            "traefik.tcp.routers.mysql-build-dashboard.rule=HostSNI(`mysql-dossier.localhost`)"
          ]
        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
    task "Start-NocoDB"{
      driver = "docker"
      
      volume_mount {
        volume      = "ca-certs"
        destination = "/etc/ssl/certs"
      }
      
      config{
        image = "nocodb/nocodb"
      }
      
      env{
        NC_DB = "mysql2://mysql-dossier.localhost:444?u=admin&p=admin@123&d=dossier"
      }

      service {
        name = "nocodb-build-dashboard"
        port = "nocodb"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.nocodb-build-dashboard.entrypoints=http",
            "traefik.http.routers.nocodb-build-dashboard.tls=true",
            "traefik.http.routers.nocodb-build-dashboard.rule=Host(`dossier.localhost`)",
          ]
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          port     = "nocodb"
          interval = "60s"
          timeout  = "5s"
          check_restart {
            limit = 2
            grace = "20s"
            ignore_warnings = false
          }
        }
      }

      lifecycle{
        hook = "poststart"
        sidecar =false
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }

    task "Start-PhpMyAdmin"{
      driver = "docker"

      volume_mount {
        volume      = "ca-certificates"
        destination = "/etc/ssl/certs"
      }

      config{
        image = "phpmyadmin"
      }

      env{
        PMA_HOST = "127.0.0.1"
        PMA_PORT = "$${NOMAD_HOST_PORT_mysql}"
      }
      service {
        name = "admin-build-dashboard"
        port = "phpmyadmin"
        tags = [
            "traefik.enable=true",
            "traefik.http.routers.admin-build-dashboard.entrypoints=http",
            "traefik.http.routers.admin-build-dashboard.tls=true",
            "traefik.http.routers.admin-build-dashboard.rule=Host(`admin-dossier.localhost`)",
          ]
        check {
          name     = "alive"
          type     = "http"
          path     = "/"
          port     = "phpmyadmin"
          interval = "60s"
          timeout  = "5s"
            check_restart {
            limit = 2
            grace = "10s"
            ignore_warnings = false
          }
        }
      }
      lifecycle{
        hook = "poststart"
        sidecar =false
      }
      resources {
        cpu    = 256
        memory = 512
        memory_max = 512
      }
    }
    network {
      port "mysql" { to = 3306 }
      port "nocodb" { to = 8080 }
      port "phpmyadmin" { to = 80 }
    }
  }
  
}