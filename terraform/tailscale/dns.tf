# Split DNS silently stops working if MagicDNS is off, so pin it on rather than
# leaving it to whatever the admin console happens to have set.
resource "tailscale_dns_preferences" "homelab" {
  magic_dns = true
}

# Routes only *.suskins.co.uk at AdGuard Home, which rewrites it to Traefik on
# 192.168.0.204 — the same resolution path LAN clients get. Every other name keeps
# using the client's normal resolver, so general DNS still works off-LAN when the
# homelab is down.
resource "tailscale_dns_split_nameservers" "internal" {
  domain      = var.internal_domain
  nameservers = [var.adguard_nameserver]
}

# ---------------------------------------------------------------------------
# FULL OVERRIDE alternative — send ALL tailnet DNS to AdGuard, giving ad-blocking
# on every device anywhere. Terraform can set the nameserver list, but the
# "Override local DNS" toggle it depends on is NOT exposed by the Tailscale API or
# this provider (tailscale/terraform-provider-tailscale#448), so it must be flipped
# by hand — full override can never be fully IaC.
#
# Trade-off: an AdGuard restart then means a total DNS outage on every tailnet
# device, and tasks/docker/adguard.yml deliberately stops the container whenever
# its rendered config changes. Do NOT add a second nameserver as a "fallback":
# clients spread queries across global nameservers, so ad-blocking would become
# intermittent and internal names would resolve only some of the time.
# ---------------------------------------------------------------------------
# resource "tailscale_dns_nameservers" "homelab" {
#   nameservers = [var.adguard_nameserver]
# }
