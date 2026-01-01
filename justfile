switch:
  sudo nixos-rebuild switch --flake .#artemis

deploy:
  sudo nixos-rebuild switch --flake .#artemis --target-host artemis --use-remote-sudo
  
debug:
  sudo nixos-rebuild switch --flake .#artemis --target-host artemis --use-remote-sudo --verbose --show-trace
