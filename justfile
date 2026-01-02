install:
  sudo nix run nixpkgs#nixos-anywhere -- --flake .#artemis --generate-hardware-config nixos-generate-config /hardware-configuration.nix root@192.168.10.129

test:
  nix run github:nix-community/nixos-anywhere -- --flake .#artemis --vm-test

rebuild:
  sudo nixos-rebuild switch --flake .#artemis --target-host root@artemis
