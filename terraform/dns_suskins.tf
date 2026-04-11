data "cloudflare_zone" "suskins" {
  filter = {
    name = "suskins.co.uk"
  }
}

# Root A record. Terraform owns the record's existence and metadata
# (type, proxied, ttl); the cloudflare-ddns container owns the IP value.
# The `content` below is a placeholder — change it to your current public
# IP before the first apply if you want to avoid a brief outage window
# while the ddns container catches up.
resource "cloudflare_dns_record" "suskins_root" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "suskins.co.uk"
  type    = "A"
  content = "192.0.2.1" # placeholder — updated out-of-band by cloudflare-ddns
  proxied = true
  ttl     = 1

  lifecycle {
    ignore_changes = [content]
  }
}

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

resource "cloudflare_dns_record" "suskins_www" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "www"
  type    = "CNAME"
  content = "suskins.co.uk"
  proxied = true
  ttl     = 1
}

# Add additional DNS records for the suskins.co.uk zone below.
