provider "google" {
  credentials = "${file("${var.credentials}")}"
  project     = "${var.gcp_project}"
  region      = "${var.region}"
}

source "google_compute_address" "harborip" {
  name   = "harborip"
  region = "us-east1"
}

resource "google_compute_instance" "harbor" {
  name         = "harbor-ashok"
  machine_type = "n1-standard-1"
  zone         = "us-east1-b"


  tags = ["name", "harbor", "http-server"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20180129"
    }
  }
 
 network_interface {
    # network = "default"

    network    = "${var.sonarvpc}"
    subnetwork = "${var.sonarsub}"
    access_config {
      // Ephemeral IP
      nat_ip       = "${google_compute_address.harborip.address}"
      network_tier = "PREMIUM"
    }
  }

  metadata = {
    name = "harbor"
  }
  description             = "${google_compute_address.harborip.address}"
  metadata_startup_script = "sudo yum update -y; sudo yum install git -y; sudo yum install wget -y; git clone https://github.com/iamdaaniyaal/gcpterraform.git; cd gcpterraform/scripts; sudo chmod 777 hb.sh; sh hb.sh"


  service_account {
    scopes = ["cloud-platform"]
  }
}


