locals {
  bad_bot_user_agents = [
    "masscan",
    "nmap",
    "nikto",
    "sqlmap",
    "zgrab",
    "semrush",
    "ahrefsbot",
    "mj12bot",
    "dotbot",
    "petalbot",
  ]

  exploit_paths = [
    "/wp-admin",
    "/wp-login.php",
    "/xmlrpc.php",
    "/.env",
    "/.git",
    "/phpmyadmin",
    "/phpMyAdmin",
    "/.aws",
    "/.ssh",
    "/server-status",
  ]
}

# Custom WAF ruleset, identical across zones apart from the allowed-country
# list. Cloudflare Free plan allows up to 5 custom rules per zone.
resource "cloudflare_ruleset" "waf" {
  for_each = local.zones

  zone_id     = each.value.zone_id
  name        = "${each.key}-waf-custom"
  description = "Custom WAF rules for ${each.value.hostname}"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      description = "Block countries outside the allowed list"
      expression  = "(not ip.src.country in {${join(" ", [for c in each.value.allowed_countries : "\"${c}\""])}})"
      action      = "block"
      enabled     = true
    },
    {
      description = "Block common exploit paths"
      expression  = "(${join(" or ", [for p in local.exploit_paths : "starts_with(http.request.uri.path, \"${p}\")"])})"
      action      = "block"
      enabled     = true
    },
    {
      description = "Block known bad bot user agents"
      expression  = "(${join(" or ", [for ua in local.bad_bot_user_agents : "lower(http.user_agent) contains \"${ua}\""])})"
      action      = "block"
      enabled     = true
    },
    {
      description = "Managed Challenge for suspicious requests (high threat score or Tor)"
      expression  = "(cf.threat_score gt 10) or (ip.src.country eq \"T1\")"
      action      = "managed_challenge"
      enabled     = true
    },
  ]
}

moved {
  from = cloudflare_ruleset.suskins_waf
  to   = cloudflare_ruleset.waf["suskins"]
}

moved {
  from = cloudflare_ruleset.pubgolf_waf
  to   = cloudflare_ruleset.waf["pubgolf"]
}

# Rate limiting rulesets (Free plan: 1 rate limit rule per zone). These differ
# per zone — suskins protects the Authelia auth endpoint, pubgolf throttles all
# traffic — so they stay as separate resources rather than a for_each.
resource "cloudflare_ruleset" "suskins_rate_limit" {
  zone_id     = local.zones.suskins.zone_id
  name        = "suskins-rate-limit"
  description = "Rate limit rules for suskins.co.uk"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [
    {
      description = "Rate limit Authelia auth endpoints"
      expression  = "(http.host eq \"authelia.suskins.co.uk\" and starts_with(http.request.uri.path, \"/api/firstfactor\"))"
      action      = "block"
      ratelimit = {
        characteristics     = ["ip.src", "cf.colo.id"]
        period              = 10
        requests_per_period = 5
        mitigation_timeout  = 10
      }
      enabled = true
    },
  ]
}

resource "cloudflare_ruleset" "pubgolf_rate_limit" {
  zone_id     = local.zones.pubgolf.zone_id
  name        = "pubgolf-rate-limit"
  description = "Rate limit rules for pubgolf.me"
  kind        = "zone"
  phase       = "http_ratelimit"

  rules = [
    {
      description = "Rate limit all pubgolf.me traffic"
      expression  = "(http.host eq \"pubgolf.me\" or ends_with(http.host, \".pubgolf.me\"))"
      action      = "block"
      ratelimit = {
        characteristics     = ["ip.src", "cf.colo.id"]
        period              = 10
        requests_per_period = 100
        mitigation_timeout  = 10
      }
      enabled = true
    },
  ]
}
