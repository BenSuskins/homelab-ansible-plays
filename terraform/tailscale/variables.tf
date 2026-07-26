variable "tailscale_oauth_client_id" {
  description = "Tailscale OAuth client ID (scopes: devices:core, dns, policy_file)"
  type        = string
}

variable "tailscale_oauth_client_secret" {
  description = "Tailscale OAuth client secret"
  type        = string
  sensitive   = true
}

variable "tailscale_tailnet" {
  description = "Tailnet name; \"-\" means the default tailnet of the credential"
  type        = string
  default     = "-"
}

variable "tailscale_tag_owner" {
  description = "Tailnet user allowed to own subnet_router_tag (e.g. an email, or autogroup:admin)"
  type        = string
}

variable "subnet_router_tag" {
  description = "ACL tag applied to the subnet router node; must match the tag on the auth key"
  type        = string
  default     = "tag:subnet-router"
}

variable "lan_cidr" {
  description = "Home LAN advertised by the subnet router; must match tailscale_routes in group_vars/docker.yml"
  type        = string
  default     = "192.168.0.0/24"
}

variable "internal_domain" {
  description = "Domain resolved by AdGuard Home for tailnet clients"
  type        = string
  default     = "suskins.co.uk"
}

# AdGuard Home's address as seen by tailnet clients. The LAN address works via the
# advertised subnet route and keeps this root plannable before the node exists. The
# router's own 100.x address is more robust (it needs no route acceptance) but is
# only knowable after first registration — swap it in as a follow-up if wanted.
variable "adguard_nameserver" {
  description = "Nameserver tailnet clients use for internal_domain"
  type        = string
  default     = "192.168.0.202"
}
