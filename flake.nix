{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-xr,
    }:
    let
      eachSystem =
        f: nixpkgs.lib.attrsets.genAttrs [ "x86_64-linux" ] (system: f nixpkgs.legacyPackages.${system});
    in
    {
      nixosConfigurations = {
        simulator =
          let
            system = "x86_64-linux";
          in
          nixpkgs.lib.nixosSystem {
            specialArgs = {
              selfpkgs = self.packages.${system};
            };
            modules = [
              { nixpkgs = { inherit system; }; }
              nixpkgs-xr.nixosModules.nixpkgs-xr
              ./machines/simulator/config.nix
            ];
          };
      };
    };
}
