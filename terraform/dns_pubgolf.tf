data "cloudflare_zone" "pubgolf" {
  filter = {
    name = "pubgolf.me"
  }
}

# Root A record. Terraform owns the record's existence and metadata
# (type, proxied, ttl); the cloudflare-ddns container owns the IP value.
# The `content` below is a placeholder — change it to your current public
# IP before the first apply if you want to avoid a brief outage window
# while the ddns container catches up.
resource "cloudflare_dns_record" "pubgolf_root" {
  zone_id = data.cloudflare_zone.pubgolf.zone_id
  name    = "pubgolf.me"
  type    = "A"
  content = "192.0.2.1" # placeholder — updated out-of-band by cloudflare-ddns
  proxied = true
  ttl     = 1

  lifecycle {
    ignore_changes = [content]
  }
}

resource "cloudflare_dns_record" "pubgolf_www" {
  zone_id = data.cloudflare_zone.pubgolf.zone_id
  name    = "www"
  type    = "CNAME"
  content = "pubgolf.me"
  proxied = true
  ttl     = 1
}

# Add DNS records for the pubgolf.me zone below.
