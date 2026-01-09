# Argus
Nix fake for a Raspberry Pi based IP-camera

## Goals
- Hardware: the project will be testing on a Raspberry Pi 4 with 1GB of RAM and the offical Rasbperry Pi camera module, but the setup should work for different Pi's and cameras
- The video stream should be optimized for [Frigate](https://frigate.video/)
- The flake should be "batteries include" but also allow from customization (hostname, IP address, etc.)

## Example Flake
```nix
# working on it..
```

## Updating
It is recommended to build on your local machine and deploy the flake to your Pi.
```nix
sudo nixos-rebuild switch --flakle .#hostame --target-host root@<ip-address/hostname>
```

> [!NOTE]
> You may have to enable arm emulation to build the flake on your local machine
```nix
# Enable arm/raspi builds
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
nix.settings.extra-platforms = [ "aarch64-linux" ];
```

## Installing for the First Time
### 1) Build the SD Card Image
- Clone the repo
```
git clone https://github.com/nvmd/nixos-raspberrypi.git
```
- `cd nixos-raspberrypi`
- Build the image
```
sudo nix build .#installerImages.rpi4
```
- Image is built in `/result/sd-image`

### 2) Decompresss
`/result` is read-only so you have to decompress the file to somewhere else:

```sh
zstd -d nixos-installer-rpi4-uboot.img.zst -o ~/nixos-rpi4.img
```

### 3) Flash USB Drive
I used: `nix-shell -p mediawriter`

### 4) Boot the Raspberry Pi from the USB Drive
- Power off the Pi
- Remove the SD card
- Connect the USB drive
- Connect monitor
- Power on
- Reinsert SD card
- Root credentials with appear on the screen after a while

### 4) Confirm Ssh Root Access
```sh
ssh root@<ip-address>
```

### 5) Build the Flake 
use `just install` to install the flake using nixos-anywhere

## References
- [nixos-raspberrypi Flake GitHub](https://github.com/nvmd/nixos-raspberrypi)
- [disko GitHub](https://github.com/nix-community/disko)
- [nixos-anywhere GitHub](https://github.com/nix-community/nixos-anywhere)
- [Raspberry Pi device tree overlay options](https://github.com/raspberrypi/linux/blob/rpi-6.6.y/arch/arm/boot/dts/overlays/README)
- [nixos discourse: how to best deploy to raspberry pi](https://discourse.nixos.org/t/how-best-to-deploy-to-raspberry-pi/70410/8)
