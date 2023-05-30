# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader Settings
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.enable = true;

  # Monthly btrfs scrubbing:
  # - Read all data and metadata blocks and verify checksums.
  # - Automatically repair corrupted blocks.
  services.btrfs.autoScrub.enable = true;

  # Virtualisation
  virtualisation.libvirtd.enable = true;

  # Networking Settings
  networking = {
    hostName = "nixos-latitude";
    networkmanager = {
      enable = true;
    };
  };

  # Graphics
  boot.initrd.kernelModules = [ "i915" ];
  environment.variables = {
    VDPAU_DRIVER = "va_gl";
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver
    ];
  };

  # Bluetooth
  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.package = pkgs.bluezFull;

  # Laptop Stuff
  hardware.enableAllFirmware = true;

  services = {
    auto-cpufreq.enable = true;
    thermald.enable = true;
    fstrim.enable = true;
    xserver.libinput.enable = true;
    # TODO blueman?
    # TODO sane?
  };
  services.picom = {
    enable = true;
    backend = "glx";
    vSync = true;
  };

  programs.light.enable = true;
  services.actkbd = {
    enable = true;
    # For some reason the correct keycode is whatever xev returns minus 8
    bindings = [
      {
        keys = [ 224 ];
        events = [ "key" ];
        command = "${pkgs.light}/bin/light -U 10";
      }
      {
        keys = [ 225 ];
        events = [ "key" ];
        command = "${pkgs.light}/bin/light -A 10";
      }
    ];
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_BAT="powersave";
      CPU_MAX_PERF_ON_BAT=75;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "video" "libvirtd" "networkmanager" "docker"];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted pciutils git iw virtmanager
  ];

  # Daemon for running docker containers
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

}
