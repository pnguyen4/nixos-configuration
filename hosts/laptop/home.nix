{ config, pkgs, lib, ... }:

{
  # User Programs
  # Does not include software enabled by options programs.* and services.*
  home.packages = with pkgs; [
    bluez                          # Bluetooth Support for Linux
    bluez-tools                    # Command Line Bluetooth Manager for Bluez5
    python311
  ];
}
