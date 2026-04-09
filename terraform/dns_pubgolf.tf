data "cloudflare_zone" "pubgolf" {
  filter = {
    name = "pubgolf.me"
  }
}

# NOTE: The root A record for pubgolf.me is managed by the
# cloudflare-ddns container (dynamic IP). Do NOT add it here.

# Add DNS records for the pubgolf.me zone below.
