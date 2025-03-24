{
  description = "Ansible development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }: let
    system = builtins.currentSystem;
  in {
    devShells.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
      packages = with nixpkgs.legacyPackages.aarch64-darwin; [
        ansible  
        ansible-lint 
        python3  
        python3Packages.pip  
      ];
      shellHook = ''
        echo "Ansible dev shell ready!"
      '';
    };
  };
}