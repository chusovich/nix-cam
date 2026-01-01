{ config, lib, pkgs, nixos-raspberrypi, ... }:

{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ./pi-configtxt.nix # boot/config.txt for raspberry pi
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  #boot.loader.grub.enable = false;
  #boot.loader.generic-extlinux-compatible.enable = true;
  
  #boot.loader.raspberryPi.enable = true;
  
  # trying to copy nvmd github example
  #system.nixos.tags = let
  #  cfg = config.boot.loader.raspberryPi;
  #in [
  #  "raspberry-pi-${cfg.variant}"
  #  cfg.bootloader
  #  config.boot.kernelPackages.kernel.version
  #];  

  # Camera packages
  environment.systemPackages = [
    nixos-raspberrypi.packages.${pkgs.system}.libcamera
    nixos-raspberrypi.packages.${pkgs.system}.rpicam-apps
  ];
 
  # Network Configuration
  networking = {
    firewall.enable = false;
    hostName = "artemis";
    interfaces = {
      end0 = {
        useDHCP = false;
        ipv4.addresses = [ {
          address = "192.168.10.203";
          prefixLength = 24;
        } ];
      };
    };
    defaultGateway = "192.168.10.1";
    nameservers = [ "192.168.10.1" ];
  };

  # Time zone.
  time.timeZone = "America/New_York";

  # Default user account
  users.users.calebh = {
    isNormalUser = true;
    description = "Caleb Husovich";
    extraGroups = [ "video" "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [ just git ];
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "yes";
    };
  };
  
  # Tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = "/home/calebh/secrets/tailscale_key";
    extraUpFlags = [
      "--reset"
      "--ssh"
      "--advertise-tags tag:server"
    ];
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };  

  # Prometheus exporter
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    enabledCollectors = [
      "logind"
      "systemd"
    ];
    disabledCollectors = [ "textfile" ];
    openFirewall = true;
    firewallFilter = "-i br0 -p tcp -m tcp --dport 9100";
  };
  
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
