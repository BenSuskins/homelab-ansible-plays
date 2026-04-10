locals {
  suskins_allowed_countries = ["GB", "FR"]
  pubgolf_allowed_countries = ["GB"]

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

# Custom WAF ruleset for suskins.co.uk
# Cloudflare Free plan allows up to 5 custom rules per zone.
resource "cloudflare_ruleset" "suskins_waf" {
  zone_id     = data.cloudflare_zone.suskins.zone_id
  name        = "suskins-waf-custom"
  description = "Custom WAF rules for suskins.co.uk"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      description = "Block countries outside UK/FR"
      expression  = "(not ip.src.country in {${join(" ", [for c in local.suskins_allowed_countries : "\"${c}\""])}})"
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

# Rate limiting ruleset (Free plan: 1 rate limit rule)
resource "cloudflare_ruleset" "suskins_rate_limit" {
  zone_id     = data.cloudflare_zone.suskins.zone_id
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
        period              = 60
        requests_per_period = 10
        mitigation_timeout  = 600
      }
      enabled = true
    },
  ]
}

# Custom WAF ruleset for pubgolf.me
resource "cloudflare_ruleset" "pubgolf_waf" {
  zone_id     = data.cloudflare_zone.pubgolf.zone_id
  name        = "pubgolf-waf-custom"
  description = "Custom WAF rules for pubgolf.me"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      description = "Block countries outside UK"
      expression  = "(not ip.src.country in {${join(" ", [for c in local.pubgolf_allowed_countries : "\"${c}\""])}})"
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
