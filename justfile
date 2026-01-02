install:
  nix run nixpkgs#nixos-anywhere -- --flake .#artemis --disk-config ./disk-config.nix --reboot --generate-hardware-config nixos-generate-config /hardware-configuration.nix root@artemis
