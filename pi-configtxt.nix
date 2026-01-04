{ config, pkgs, lib, ... }:

{
  hardware.raspberry-pi.config.all = {
  dt-overlays = {
    vc4-kms-v3d = {
      enable = true;
      params = { 
        cma-128.enable = true; # set cma memory to 128MB, defaults of 512MB is to high for RPi4 4GM RAM 
      };
    };
  };
};
