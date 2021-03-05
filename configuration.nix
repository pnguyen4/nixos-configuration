# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    rev = "f33be4894cf5260f99d95ecd750c783837f33cfd";
    ref = "release-20.09";
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Home-Manager Module
    (import "${home-manager}/nixos")
  ];

  # Bootloader Settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NTFS support via FUSE
  boot.supportedFilesystems = [ "ntfs" ];

  # Automatic Garbage Collection of Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Save Space by Optimizing the Store (hardlink identical files)
  nix.autoOptimiseStore = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Networking Settings
  networking = {
    hostName = "nixos-machine";
    useDHCP = false;
    interfaces.enp0s25.useDHCP = true;
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "dvorak";
  };

  # Configure X Server and Window Manager
  services.xserver = {
    enable = true;
    # Configure keymap in X11
    layout = "us";
    xkbVariant = "dvorak";
    # No more screen tearing!
    deviceSection = ''
      Option "TearFree" "true"
    '';
    # NixOS uses systemd to launch x11 but at least this way xorg runs rootless
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
  };

  # Configure video drivers
  services.xserver.videoDrivers = [ "modesetting" ];
  services.xserver.useGlamor = true;
  services.acpid.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" "jupyter" ];
  };
  home-manager.users.user = import /home/user/home.nix;
  home-manager.useGlobalPkgs = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted pciutils git gnomeExtensions.appindicator
  ];

  environment.gnome3.excludePackages = with pkgs; [
    gnome3.geary gnome3.gnome-music gnome3.gnome-terminal epiphany evince
    gnome3.gnome-calculator gnome3.gnome-calendar gnome3.gnome-contacts
    gnome3.gnome-weather gnome3.gnome-characters gnome3.gnome-disk-utility
    gnome3.gnome-system-monitor gnome3.cheese gnome3.file-roller gnome3.gedit
    gnome3.gnome-font-viewer gnome3.gnome-maps gnome3.totem gnome3.eog
    gnome3.gnome-screenshot gnome3.seahorse gnome-photos baobab xterm
    gnome3.gnome-logs gnome3.gnome-clocks
  ];

  # Ricing
  programs.dconf.enable = true;
  fonts.fonts = with pkgs; [
    ibm-plex
    noto-fonts
    noto-fonts-cjk
    symbola
    terminus_font
  ];

  services.udev.packages = with pkgs; [gnome3.gnome-settings-daemon ];

  # Sorry Stallman Senpai
  nixpkgs.config.allowUnfree = true;

  # Security Settings
  security.hideProcessInformation = true;
  security.protectKernelImage = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome3.gnome-keyring.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
