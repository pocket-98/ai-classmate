{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
    nix-hermes.url = "github:0xrsydn/nix-hermes-agent";
  };
  outputs = { self, nixpkgs, home-manager, llm-agents, nix-hermes, ... }@inputs: {
    nixosConfigurations."ai-classmate" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        home-manager.nixosModules.home-manager
        nix-hermes.nixosModules.hermes-agent
        {
          nixpkgs.config.allowUnfree = true;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users."pocket" = import ./home.nix;
          home-manager.users."root" = import ./roothome.nix;
        }
      ];
    };
  };
}
