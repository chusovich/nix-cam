{ disk, pkgs, ... }:
let
  configTxt = pkgs.writeText "config.txt" ''
    [pi4]
    kernel=u-boot-rpi4.bin
    enable_gic=1

    # Otherwise the resolution will be weird in most cases, compared to
    # what the pi3 firmware does by default.
    disable_overscan=1

    # Supported in newer board revisions
    arm_boost=1

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    avoid_warnings=1
  '';
in
{
  disko.devices.disk."${disk}" = {
    type = "disk";
    device = "/dev/${disk}";
    content = {
      type = "gpt";
      partitions = {
        firmware = {
          size = "60M";
          priority = 1;
          type = "0700";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/firmware";
            postMountHook = toString (
              pkgs.writeScript "postMountHook.sh" ''
                (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf *.dtb /mnt/firmware/)
                cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin /mnt/firmware/u-boot-rpi4.bin
                cp ${configTxt} /mnt/firmware/config.txt
              ''
            );
          };
        };
        ESP = {
          type = "EF00";
          size = "2G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ]; # Override existing partition
            subvolumes = {
              "root" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/";
              };
              "home" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/home";
              };
              "nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/nix";
              };
              "persistent" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
                mountpoint = "/persistent";
              };
            };
            postCreateHook = ''
              MNTPOINT=$(mktemp -d)
              mount /dev/disk/by-partlabel/disk-${disk}-root "$MNTPOINT" -o subvol=/
              trap 'umount $MNTPOINT; rm -rf $MNTPOINT' EXIT
              btrfs subvolume snapshot -r $MNTPOINT/root $MNTPOINT/root-blank
            '';
          };
        };
      };
    };
  };
  fileSystems."/persistent".neededForBoot = true;
}
