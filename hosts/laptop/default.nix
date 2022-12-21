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
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
  };

  # TODO filesystems, boot device, swap
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking Settings
  networking = {
    hostName = "nixos-traveller";
    networkmanager = {
      enable = true;
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.package = pkgs.bluezFull;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "input" "video"];
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    wget vim parted git
  ];

}
