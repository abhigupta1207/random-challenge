resource "google_compute_network" "vpc_network" {
  name                    = "vpc-test"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "test_subnet" {
  name          = "test-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}
