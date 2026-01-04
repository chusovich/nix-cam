{ config, pkgs, lib, ... }:

{
  hardware = {
    i2c.enable = true;
    raspberry-pi.config.all = {
      dt-overlays = {
        vc4-kms-v3d = {
          enable = lib.mkDefault true;
          params = { cma-128.enable = true; };
        };
      };
    };
  };
}
