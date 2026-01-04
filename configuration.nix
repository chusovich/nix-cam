{ disk, config, modulesPath, lib, pkgs, nixos-raspberrypi, ... } @ args:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./hardware-configuration.nix # Include the results of the hardware scan.
#    ./pi-configtxt.nix # boot/config.txt for raspberry pi
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  users.users.root.initialPassword = "artemis";
  users.users.root.openssh.authorizedKeys.keys = [
    # change this to your ssh key
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII23H7VPE8Fwz0y2dbWPGedl2uleLkscGlsC+Bi+oUxX calebmhusovich@gmail.com" # for user calebh
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC8a816Tm9KOj9mpRBYjh11INcimLwmsvKs9kuwY12Nx calebmhusovich@gmail.com" # for root, passphrase: artemis

  ];

  # Camera packages
  environment = {
    systemPackages = with pkgs; [
      rpi.libcamera
      rpi.rpicam-apps  
    ];
  };

/*
  # Setup video streaming
  services.go2rtc = {
    enable = true;
    settings = {
      streams.cam =
        "exec:${pkgs.rpi.rpicam-apps}/bin/libcamera-vid -t 0 -n --inline --width 1440 --height 1080 --framerate 30 -o -";
      api = {
        listen = ":1984";
        origin = "*";
      };
      webrtc.listen = ":8555";
      rtsp.listen = "";
      rtmp.listen = "";
    };
  };
*/

  #Network Configuration
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
    initialPassword = "artemis";
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
    enable = false;
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
