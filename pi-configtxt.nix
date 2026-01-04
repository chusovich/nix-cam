{ config, pkgs, lib, ... }:

{
  hardware = {
    raspberry-pi.config.all = {
      dt-overlays = {
        cma = {
          enable = true;
          params = {
            cma = {
              enable = true; 
              value = "cma-128";
            };
          };
        };
      };
    };
  };
}
