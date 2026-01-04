{ config, pkgs, lib, ... }:

{
  hardware = {
    i2c.enable = true;
    raspberry-pi.config.all = {
      dt-overlays = {
        imx219 = { # camera model
          enable = true;
          params = {};
        };
      };
 
     base-dt-params = {
        camera_auto_detect = {
          enable = true;
          value = false;
        };
        i2c_arm = {
          enable = true;
          value = "on";
        };
        i2c_arm_baudrate = {
          enable = true;
          value = 1000000;
        };
      };
    };
  };
}
