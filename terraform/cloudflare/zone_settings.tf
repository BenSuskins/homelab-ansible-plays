locals {
  # Zone settings applied identically to every zone in local.zones.
  cloudflare_zone_settings = {
    ssl                      = "strict"
    always_use_https         = "on"
    automatic_https_rewrites = "on"
    min_tls_version          = "1.2"
    tls_1_3                  = "on"
    opportunistic_encryption = "on"
    "0rtt"                   = "on"
    brotli                   = "on"
  }

  zone_setting_pairs = {
    for pair in setproduct(keys(local.zones), keys(local.cloudflare_zone_settings)) :
    "${pair[0]}_${pair[1]}" => {
      zone_id    = local.zones[pair[0]].zone_id
      setting_id = pair[1]
      value      = local.cloudflare_zone_settings[pair[1]]
    }
  }
}

resource "cloudflare_zone_setting" "hardening" {
  for_each = local.zone_setting_pairs

  zone_id    = each.value.zone_id
  setting_id = each.value.setting_id
  value      = each.value.value
}

resource "cloudflare_zone_setting" "hsts" {
  for_each = local.zones

  zone_id    = each.value.zone_id
  setting_id = "security_header"
  value = {
    strict_transport_security = {
      enabled            = true
      max_age            = 31536000
      include_subdomains = true
      preload            = true
      nosniff            = true
    }
  }
}
