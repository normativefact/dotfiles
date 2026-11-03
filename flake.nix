{
  description = "Nix Hyprland Set up";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    antigravityOverlay = final: prev: {
      antigravity-cli = prev.stdenv.mkDerivation rec {
        pname = "google-antigravity-cli";
        version = "1.4.12-4768735748292608";

        src = prev.fetchurl {
          url = "https://storage.googleapis.com/antigravity-public/antigravity-cli/${version}/linux-x64/cli_linux_x64.tar.gz";
          hash = "sha512-6gHHO3chh7ypKIUs+WI18NhG1tpevawYi5rnGVl0ZXN/MlVA1IPuXz9i0VECkAFxM0SXKhh937mMx7l/cgS39A==";
        };

        nativeBuildInputs = [
          prev.autoPatchelfHook
        ];

        sourceRoot = ".";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin
          cp antigravity $out/bin/agy
          ln -s $out/bin/agy $out/bin/antigravity

          runHook postInstall
        '';

        meta = {
          description = "Google Antigravity CLI";
          homepage = "https://antigravity.google";
          mainProgram = "agy";
        };
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ antigravityOverlay ];
    };
  in {
    packages.${system} = {
      antigravity-cli = pkgs.antigravity-cli;
      default = pkgs.antigravity-cli;
    };

    overlays.default = antigravityOverlay;

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        { nixpkgs.overlays = [ antigravityOverlay ]; }
        ./nixos/configuration.nix
      ];
    };

    homeConfigurations.normativefact = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./home-manager/home.nix
        inputs.stylix.homeModules.stylix
        inputs.niri.homeModules.niri
      ];
    };
  };
}
