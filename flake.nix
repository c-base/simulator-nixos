{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-xr,
      home-manager,
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
                        inputs.home-manager.nixosModules.home-manager
                      ];
                    };
                    inherit inputs;
                  };
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.backupFileExtension = "hm-bak";
                }
              )
              nixpkgs-xr.nixosModules.nixpkgs-xr
              inputs.home-manager.nixosModules.home-manager
              ./machines/simulator/config.nix
            ];
          };
      };
    };
}
