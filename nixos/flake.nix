{
  description = "Nix Hyprland Set up";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
    };

  };
  outputs = inputs @ { self, nixpkgs, hyprland,...}: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules = [ 
      ./configuration.nix 
      ./hardware-configuration.nix 
      inputs.catppuccin.nixosModules.catppuccin ];
    };
  };
}
