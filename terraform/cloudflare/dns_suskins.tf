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

resource "cloudflare_dns_record" "wedding" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "wedding"
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

# iCloud Custom Email Domain — DKIM, MX, SPF, and Apple domain verification.
# These are public records (DNS is public) so safe to codify here.

resource "cloudflare_dns_record" "suskins_dkim_sig1" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "sig1._domainkey"
  type    = "CNAME"
  content = "sig1.dkim.suskins.co.uk.at.icloudmailadmin.com"
  proxied = false
  ttl     = 3600
}

resource "cloudflare_dns_record" "suskins_mx_01" {
  zone_id  = data.cloudflare_zone.suskins.zone_id
  name     = "suskins.co.uk"
  type     = "MX"
  content  = "mx01.mail.icloud.com"
  priority = 10
  proxied  = false
  ttl      = 3600
}

resource "cloudflare_dns_record" "suskins_mx_02" {
  zone_id  = data.cloudflare_zone.suskins.zone_id
  name     = "suskins.co.uk"
  type     = "MX"
  content  = "mx02.mail.icloud.com"
  priority = 10
  proxied  = false
  ttl      = 3600
}

resource "cloudflare_dns_record" "suskins_spf" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "suskins.co.uk"
  type    = "TXT"
  content = "\"v=spf1 include:icloud.com ~all\""
  proxied = false
  ttl     = 3600
}

resource "cloudflare_dns_record" "suskins_apple_domain_1" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "suskins.co.uk"
  type    = "TXT"
  content = "\"apple-domain=WV7HZjQdwGJE5Yf1\""
  proxied = false
  ttl     = 3600
}

resource "cloudflare_dns_record" "suskins_apple_domain_2" {
  zone_id = data.cloudflare_zone.suskins.zone_id
  name    = "suskins.co.uk"
  type    = "TXT"
  content = "\"apple-domain=9ycj5VmPcq7csjJH\""
  proxied = false
  ttl     = 3600
}

# Add additional DNS records for the suskins.co.uk zone below.
