{ config, pkgs, lib, ... }:

{
  # User Programs
  # Does not include software enabled by options programs.* and services.*
  home.packages = with pkgs; [
    # General Applications
    audacity                       # Audio Editor and Recording Software
    darktable                      # Virtual Lighttable and Darkroom for Photographers
    desmume                        # Nintendo DS Emulator
    gimp                           # The GNU Image Manipulation Program
    libsForQt5.kdenlive            # Video Editor
    unstable.ledger-live-desktop
    melonDS                        # WIP Nintendo DS Emulator
    monero-gui
    unstable.nyxt
    obs-studio                     # Video Recording and Live Streaming Software
    prismlauncher                  # Open Source Minecraft Launcher
    runelite                       # Old School Runescape
    signal-desktop                 # Encrypted Messaging
    vlc                            # Personally, just for CD/DVD playback

    # Development
    racket                         # For SICP

    # Utilities
    autorandr                      # Create and Apply Display Profiles
    #bluez                          # Bluetooth Support for Linux
    #bluez-tools                    # Command Line Bluetooth Manager for Bluez5
    # easyeffects                   # useless without pipewire
    ffmpeg                         # Record, Convert, and Stream Audio and Video
    poppler_utils                  # Includes pdftotext utility for checking resume ATS friendliness
    smartmontools                  # Get HDD SMART Information
    woeusb                         # Create Bootable USB Disks from Windows ISO Images
  ];

  xsession.windowManager.i3.config = {
    gaps = {
      inner = 12;
      outer = 3;
      smartGaps = true;
    };
    workspaceOutputAssign = [
      # My preferred scheme is to have odd numbered workspaces on
      # left monitor counting up and even numbered workspaces on
      # right monitor counting down. Don't know why, but it works.
      {
        output = "DisplayPort-1";
        workspace = "1";
      }

      {
        output = "DisplayPort-3";
        workspace = "10";
      }
    ];
  };

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
        exec = ''if [[ $(ifconfig | grep -E 'tun0|^wg-') ]]; then echo "%{F#00cc66}VPN On"; else echo "%{F#ff3333}VPN Off"; fi'';
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

  # My Cooler Master MM710 Thumb Button Preference
  home.file.".xbindkeysrc".text = ''
    "xvkbd -text "\[Left]""
      m:0x0 + b:8
    "xvkbd -text "\[Right]""
      m:0x0 + b:9
  '';

  # Automatically Apply Monitor Settings On Boot
  programs.autorandr = {
    enable = true;
    profiles = {
      "default" = {
        fingerprint = {
          "DisplayPort-1" = "00ffffffffffff000472280601010101321a0103803c22782adcf1a655519d260e5054bfef8081c08140818090409500a940b300a9c0866f80a0703840403020350056502100001e023a801871382d40582c450056502100001e000000fd0030780fb408000a202020202020000000fc00454432373320410a202020202001bf020327f14b010304050790121314161f230907078301000065030c001000681a00000101307800023a801871382d40582c450056502100001e866f80a0703840403020350056502100001e011d007251d01e206e28550056502100001e866f80a0703840403020350056502100001e0000000000000000000000000000000073";
          "DisplayPort-3" = "00ffffffffffff0010acb8a04c303635311c0104a53420783a0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e3843353536304c0a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a202020202020013502031cf14f9005040302071601141f12132021222309070783010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e96000644210000180000000000000000000000000000000000000000000000000000000c";
        };
        config = {
          "DisplayPort-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "119.98";
          };
          "DisplayPort-3" = {
            enable = true;
            crtc = 1;
            position = "1920x0";
            rotate = "right";
            mode = "1920x1200";
            rate = "59.95";
          };
        };
      };
    };
  };

}
