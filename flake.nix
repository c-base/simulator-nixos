{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-xr,
    }@inputs:
    let
      eachSystem =
        f: nixpkgs.lib.attrsets.genAttrs [ "x86_64-linux" ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = eachSystem (pkgs: {
        overte-vr-appimage = pkgs.callPackage ./packages/overte-vr-appimage.nix { };
      });
      nixosConfigurations = {
        simulator =
          let
            system = "x86_64-linux";

            allowedUnfree = [
              "steam"
              "steam-unwrapped"

              "nvidia-x11"
            ];
            allowedInsecure = [ ];
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              selfpkgs = self.packages.${system};
            };
            modules = [
              (
                { lib, ... }:
                {
                  nix.registry.n.flake = nixpkgs;
                  nixpkgs = {
                    hostPlatform = system;
                    config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfree;
                    config.permittedInsecurePackages = allowedInsecure;
                  };
                  _module.args = {
                    selfpkgs = self.packages.${system};
                    nixpkgs-unstable = import nixpkgs-unstable {
                      inherit system;
                      config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) allowedUnfree;
                      config.permittedInsecurePackages = allowedInsecure;
                      overlays = [
                        inputs.nixpkgs-xr.overlays.default
                      ];
                    };
                    inherit inputs;
                  };
                }
              )
              nixpkgs-xr.nixosModules.nixpkgs-xr
              ./machines/simulator/config.nix
            ];
          };
      };
    };
}
