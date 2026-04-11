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

resource "cloudflare_ruleset" "suskins_redirects" {
  zone_id     = data.cloudflare_zone.suskins.zone_id
  name        = "suskins-redirects"
  description = "Dynamic redirects for suskins.co.uk"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      description = "Redirect www.suskins.co.uk to apex"
      expression  = "(http.host eq \"www.suskins.co.uk\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://suskins.co.uk\", http.request.uri.path)"
          }
          preserve_query_string = true
        }
      }
      enabled = true
    },
  ]
}

resource "cloudflare_ruleset" "pubgolf_redirects" {
  zone_id     = data.cloudflare_zone.pubgolf.zone_id
  name        = "pubgolf-redirects"
  description = "Dynamic redirects for pubgolf.me"
  kind        = "zone"
  phase       = "http_request_dynamic_redirect"

  rules = [
    {
      description = "Redirect www.pubgolf.me to apex"
      expression  = "(http.host eq \"www.pubgolf.me\")"
      action      = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://pubgolf.me\", http.request.uri.path)"
          }
          preserve_query_string = true
        }
      }
      enabled = true
    },
  ]
}

# Response header transform rules — inject security headers at the edge.

resource "cloudflare_ruleset" "suskins_response_headers" {
  zone_id     = data.cloudflare_zone.suskins.zone_id
  name        = "suskins-response-headers"
  description = "Inject security response headers for suskins.co.uk"
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

resource "cloudflare_ruleset" "pubgolf_response_headers" {
  zone_id     = data.cloudflare_zone.pubgolf.zone_id
  name        = "pubgolf-response-headers"
  description = "Inject security response headers for pubgolf.me"
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
