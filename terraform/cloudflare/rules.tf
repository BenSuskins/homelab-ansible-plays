locals {
  security_response_headers = {
    "Referrer-Policy" = {
      operation = "set"
      value     = "strict-origin-when-cross-origin"
    }
    "X-Content-Type-Options" = {
      operation = "set"
      value     = "nosniff"
    }
    "X-Frame-Options" = {
      operation = "set"
      value     = "SAMEORIGIN"
    }
  }
}

# Redirect rules — canonicalize www to apex.

resource "cloudflare_ruleset" "redirects" {
  for_each = local.zones

  zone_id     = each.value.zone_id
  name        = "${each.key}-redirects"
  description = "Dynamic redirects for ${each.value.hostname}"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      description = "Redirect www.${each.value.hostname} to apex"
      expression  = "(http.host eq \"www.${each.value.hostname}\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://${each.value.hostname}\", http.request.uri.path)"
          }
          preserve_query_string = true
        }
      }
      enabled = true
    },
  ]
}

moved {
  from = cloudflare_ruleset.suskins_redirects
  to   = cloudflare_ruleset.redirects["suskins"]
}

moved {
  from = cloudflare_ruleset.pubgolf_redirects
  to   = cloudflare_ruleset.redirects["pubgolf"]
}

# Response header transform rules — inject security headers at the edge.

resource "cloudflare_ruleset" "response_headers" {
  for_each = local.zones

  zone_id     = each.value.zone_id
  name        = "${each.key}-response-headers"
  description = "Inject security response headers for ${each.value.hostname}"
  kind        = "zone"
  phase       = "http_response_headers_transform"

  rules = [
    {
      description = "Set security response headers"
      expression  = "true"
      action      = "rewrite"
      action_parameters = {
        headers = local.security_response_headers
      }
      enabled = true
    },
  ]
}

moved {
  from = cloudflare_ruleset.suskins_response_headers
  to   = cloudflare_ruleset.response_headers["suskins"]
}

moved {
  from = cloudflare_ruleset.pubgolf_response_headers
  to   = cloudflare_ruleset.response_headers["pubgolf"]
}
