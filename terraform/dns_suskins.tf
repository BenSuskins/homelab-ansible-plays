data "cloudflare_zone" "suskins" {
  filter = {
    name = "suskins.co.uk"
  }
}

# NOTE: The root A record for suskins.co.uk is managed by the
# cloudflare-ddns container (dynamic IP). Do NOT add it here.

resource "cloudflare_dns_record" "authelia" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "authelia"
  type    = "CNAME"
  content = "suskins.co.uk"
  proxied = true
  ttl     = 1
}

resource "cloudflare_dns_record" "hub" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "hub"
  type    = "CNAME"
  content = "suskins.co.uk"
  proxied = true
  ttl     = 1
}

# Add additional DNS records for the suskins.co.uk zone below.
