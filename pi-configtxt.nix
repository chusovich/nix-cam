{ config, pkgs, lib, ... }:

{
  hardware.raspberry-pi.config.all = {
    options = { };
    dt-overlays = { 
      cma = {
        enable = true;
        params = { cma = "cma-128" };
      };
    };
  };
}
