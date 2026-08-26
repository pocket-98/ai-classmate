{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations."ai-classmate" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
