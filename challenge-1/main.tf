resource "google_compute_instance_template" "app_server_template" {
  name = "app-server-template"

  machine_type = "n1-standard-1"
  tags         = ["http-server"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.test_subnet.self_link
  }
}

resource "google_compute_instance_group_manager" "app_server_group_manager" {
  name               = "app-server-group-manager"
  base_instance_name = "app-server"
  zone               = "europe-west1-b"
  version {
    instance_template = google_compute_instance_template.app_server_template.self_link
  }

  target_size = 2

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_http_health_check.app_server_health_check.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_http_health_check" "app_server_health_check" {
  name                = "app-server-health-check"
  request_path        = "/health"
  check_interval_sec  = 1
  timeout_sec         = 1
  healthy_threshold   = 1
  unhealthy_threshold = 1
}

resource "google_compute_global_address" "lb_ip_address" {
  name = "lb-ip-address"
}

resource "google_compute_global_forwarding_rule" "app_forwarding_rule" {
  name       = "app-forwarding-rule"
  target     = google_compute_target_http_proxy.lb_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip_address.address
}

resource "google_compute_target_http_proxy" "lb_proxy" {
  name    = "lb-proxy"
  url_map = google_compute_url_map.lb_map.self_link
}

resource "google_compute_url_map" "lb_map" {
  name            = "lb-map"
  default_service = google_compute_backend_service.app_service.self_link
}

resource "google_compute_backend_service" "app_service" {
  name = "app-service"
  backend {
    group = google_compute_instance_group_manager.app_server_group_manager.instance_group
  }
  health_checks = [
    google_compute_http_health_check.app_server_health_check.self_link
  ]
}
