locals {
  # Single source of truth for every managed zone. Rulesets, zone settings and
  # other per-zone resources fan out over this map with for_each, so the two
  # zones can never drift apart.
  zones = {
    suskins = {
      zone_id           = data.cloudflare_zone.suskins.zone_id
      hostname          = "suskins.co.uk"
      allowed_countries = ["GB", "FR"]
    }
    pubgolf = {
      zone_id           = data.cloudflare_zone.pubgolf.zone_id
      hostname          = "pubgolf.me"
      allowed_countries = ["GB"]
    }
  }
}
