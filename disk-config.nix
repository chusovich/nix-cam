{ lib, ... }:

{
  disko.devices = {
    disk = {
      mmc = {
        type = "disk";
        device = "/dev/mmcblk0";

        content = {
          type = "gpt";
          partitions = {
            firmware = {
              label = "FIRMWARE";
              name = "firmware";
              size = "1G";
              type = "EF00"; # EFI System Partition (works for Pi firmware)
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = [ "defaults" ];
              };
            };

            root = {
              label = "NIXOS_SD";
              name = "root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
