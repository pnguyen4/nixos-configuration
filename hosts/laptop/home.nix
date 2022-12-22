{ config, pkgs, lib, ... }:

{
  # User Programs
  # Does not include software enabled by options programs.* and services.*
  home.packages = with pkgs; [
    bluez                          # Bluetooth Support for Linux
    bluez-tools                    # Command Line Bluetooth Manager for Bluez5
    python311
  ];

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    config = {
      "bar/bottom" = {
        bottom = true;
        enable-ipc = true;
        font-0 = "Iosevka Extended:size=9;3";
        font-1 = "Noto Sans Mono CJK JP:size=9;3";
        locale = "en_US.UTF8";
        modules-left = "i3 xwindow";
        modules-right = "xkeyboard vpn date";
        monitor = "\${env:MONITOR:}";
        padding-right = 1;
        tray-offset-y = 1;
        tray-position = "right";
      };
      "module/battery" = {
        full-at = 99;
        low-at = 5;
        battery = "BAT0";
        adapter = "AC";
        type = "internal/battery";
      };
      "module/date" = {
        date = "%a %b %d";
        format = "| <label>";
        label = "%date% %time%";
        time = "%H:%M";
        type = "internal/date";
      };
      "module/i3" = {
        enable-scroll = true;
        format = "<label-state> <label-mode> ";
        label-focused-background = "#285577";
        label-focused-padding-right = 1;
        label-mode-background = "900000";
        label-visible-background= "#5f676a";
        label-visible-padding-right = 1;
        label-unfocused-background = "#222222";
        label-unfocused-padding-right = 1;
        label-urgent-background = "#900000";
        label-urgent-padding-right = 1;
        pin-workspaces = true;
        type = "internal/i3";
      };
      "module/vpn" = {
        exec = ''if [[ $(ifconfig | grep tun0) ]]; then echo "%{F#00cc66}VPN On"; else echo "%{F#ff3333}VPN Off"; fi'';
        format = "<label> ";
        type = "custom/script";
      };
      "module/xkeyboard" = {
        format = "<label-layout> | ";
        label-layout = "%name%";
        type = "internal/xkeyboard";
      };
      "module/xwindow" = {
        format = " <label>";
        label-maxlen = 150;
        type = "internal/xwindow";
      };
    };
    script = ""; # handle this in window manager
  };
}
