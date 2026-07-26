# This resource owns the ENTIRE tailnet policy file. If the policy has ever been
# hand-edited in the admin console, import it before the first apply or those edits
# are lost:
#   terraform import tailscale_acl.homelab acl
resource "tailscale_acl" "homelab" {
  acl = jsonencode({
    tagOwners = {
      (var.subnet_router_tag) = [var.tailscale_tag_owner]
    }

    # Auto-approves the advertised LAN route, so a rebuilt subnet router needs no
    # admin-console click. That matters because a rebuild may well happen while
    # you are off-LAN and depending on this route to get back in.
    autoApprovers = {
      routes = {
        (var.lan_cidr) = [var.subnet_router_tag]
      }
    }

    acls = [
      {
        action = "accept"
        src    = ["autogroup:member"]
        dst    = ["*:*"]
      },
    ]
  })
}
