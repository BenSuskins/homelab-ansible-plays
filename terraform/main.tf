terraform {
  required_version = ">= 1.5"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "homelab-terraform-state"
    key    = "cloudflare-dns/terraform.tfstate"

    # Cloudflare R2 endpoint — replace <ACCOUNT_ID> with your Cloudflare account ID
    endpoints = {
      s3 = "https://5f5532f14ac2515183403022a0148383.r2.cloudflarestorage.com"
    }

    region                      = "auto"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
