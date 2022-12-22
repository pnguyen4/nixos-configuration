{lib, inputs, nixpkgs, nixpkgs-unstable, home-manager, nur}:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [ nur.overlay overlay-unstable ];
  };
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
    specialArgs = { inherit inputs pkgs; };
    modules = [
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
    specialArgs = { inherit inputs pkgs; };
    modules = [
      # System Configuration
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
