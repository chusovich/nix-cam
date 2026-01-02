# Argus
 
Nix based ip-camera for the raspberry pi

## Building the SD Image

To build the SD image you need to have `nix` installed on an aarch64-linux
platform or proper emulation support for the aarch64-linux platform. Also add
the caches for the `nixos-raspberrypi` flake to the build system so the build
finishes in a reasonable time. Run the command for the specific Pi and camera
module you want to use:

```sh
nix build .#pi3-ov5647
nix build .#pi3-imx219
nix build .#pi3-imx477
nix build .#pi4-ov5647
nix build .#pi4-imx219
nix build .#pi4-imx477
```

When you have built the image you can list it out with the following command:

```sh
ls -lh result/sd-image
```

This will include the size of the image in the output. The image is compressed
with zstd.

## Flashing the SD Card

We need to plug in the SD card and find out what the device path is for the
SD card.

On linux:

```sh
lsblk
```

On darwin:

```sh
diskutil list
```

On linux it is usually `/dev/sdX` where `X` is a letter, for example `/dev/sdb`.
On darwin it is usually `/dev/diskX` where `X` is a number for example
`/dev/disk6`.

To flash the image to the SD card you can use the following command, make sure
to replace `/dev/XXX` with the correct device path for your SD card:

```sh
zstd -dc result/sd-image/*.zst | sudo dd of=/dev/XXX bs=4M status=progress oflag=sync
```

Flashing the SD card on windows is a little more complicated. It is not possible
to build the image on Windows and the commands will not work. Instead start by
downloading the image you want to use form the release page on GitHub. The
image will be in a `.zst` file format.

Make sure you have 7-Zip installed, and right-click the `sd-image` zst file and
select "Extract Here" to extract the image file.

Next make sure you have Rufus installed, and open it.
Select the SD card from the "Device" dropdown.
Click "Select" and choose the extracted .img file.
Click "Start" to begin flashing the SD card.

## Raspberry Pi

If you have reflashed the SD card, you may need to delete the known hosts entry
for the Pi before connecting:

```sh
ssh-keygen -R 10.10.10.10
```

### WiFi Connection

To connect to a WiFi network on the Pi, use the following commands:

1. List available WiFi networks:

   ```sh
   nmcli device wifi list
   ```

2. Connect to a WiFi network:

   ```sh
   nmcli device wifi connect "NETWORK_NAME" password "PASSWORD"
   ```

3. Check connection status:

   ```sh
   nmcli connection show
   ```

### Firmware Service Management

The Manafish firmware runs as a systemd service. It is set to run automatically
on startup, but during development it can be useful to stop/start/restart it.
Here are the common commands to manage it:

1. Start the firmware service:

   ```sh
   sudo systemctl start manafish-firmware
   ```

2. Stop the firmware service:

   ```sh
   sudo systemctl stop manafish-firmware
   ```

3. Restart the firmware service:

   ```sh
   sudo systemctl restart manafish-firmware
   ```

4. Check the service status:

   ```sh
   sudo systemctl status manafish-firmware
   ```

5. Disable the service from starting on boot:

   ```sh
   sudo systemctl disable manafish-firmware
   ```

6. View service logs:

  ```sh
  journalctl -u manafish-firmware -f
  ```

## License

This project is licensed under the GNU Affero General Public License v3.0 or
later - see the [LICENSE](LICENSE) file for details.
