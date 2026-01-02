{
  description = "Raspberry Pi 4 with camera support";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    disk = { disk = "mmcblk0"; };
  };

  # Optional: Binary cache for the flake
  nixConfig = {
    extra-substituters = [
      "https://nixos-raspberrypi.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  outputs = { self, disk, nixpkgs, nixos-raspberrypi, disko }: 
  {
    nixosConfigurations.artemis = nixos-raspberrypi.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit disk nixos-raspberrypi nixpkgs; };
      modules = [
        disko.nixosModules.disko        
        ./configuration.nix
        ({ config, pkgs, lib, nixos-raspberrypi, ... }: {
          imports = with nixos-raspberrypi.nixosModules; [
            # Hardware configuration
            raspberry-pi-4.base
            raspberry-pi-4.display-vc4
            raspberry-pi-4.bluetooth
          ];
        })
      ];
    };
  };
}

