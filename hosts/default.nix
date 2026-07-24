{lib, inputs, nixpkgs, nixpkgs-unstable, home-manager }:

let
  system = "x86_64-linux";
  overlay-unstable = final: prev: {
    unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  lib = nixpkgs.lib;
in {
  # Main Desktop
  nixos-machine = lib.nixosSystem {
    inherit system;
    # specialArgs = { inherit inputs pkgs; };
    specialArgs = { inherit inputs; };
    modules = [
      {
        nixpkgs.overlays = [ overlay-unstable ];
        nixpkgs.config.allowUnfree = true;
      }
      # System Configuration
      ./desktop
      ./configuration-common.nix
      # Home Configuration as a module
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.user = {
          imports = [ ./desktop/home.nix ./home-common.nix ];
        };
      }
    ];
  };

  # Main Laptop
  nixos-latitude = lib.nixosSystem {
    inherit system;
    # specialArgs = { inherit inputs pkgs; };
    specialArgs = { inherit inputs; };
    modules = [
      # System Configuration
      {
        nixpkgs.overlays = [ overlay-unstable ];
        nixpkgs.config.allowUnfree = true;
      }
      ./laptop
      ./configuration-common.nix
      # Home Configuration as a module
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.user = {
          imports = [ ./laptop/home.nix ./home-common.nix ];
        };
      }
    ];
  };
}
