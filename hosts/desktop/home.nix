{ config, pkgs, lib, ... }:

let my-python-packages = python-packages: with python-packages; [
      matplotlib              # plotting library
      numpy                   # numerical python for data science
      pybullet                # Physics Engine for Robot Simulation
      pyflakes                # For Doom Emacs Python Linting
      pytest                  # Framework for Writing Python Tests
      pip
    ];
    python-with-my-packages = pkgs.python3.withPackages my-python-packages;
in
{
  # User Programs
  # Does not include software enabled by options programs.* and services.*
  home.packages = with pkgs; [
    # General Applications
    audacity                       # Audio Editor and Recording Software
    darktable                      # Virtual Lighttable and Darkroom for Photographers
    desmume                        # Nintendo DS Emulator
    discord                        # Voice and Text Chat for Gamers
    gimp                           # The GNU Image Manipulation Program
    libsForQt5.kdenlive            # Video Editor
    melonDS                        # WIP Nintendo DS Emulator
    unstable.nyxt
    obs-studio                     # Video Recording and Live Streaming Software
    qbittorrent                    # GUI Torrent Client
    runelite                       # Old School Runescape
    signal-desktop                 # Encrypted Messaging
    vlc                            # Personally, just for CD/DVD playback
    xournalpp                      # Edit and Annotate PDFs

    # Development
    python-with-my-packages        # Guido's Programming Language WITH packages in path
    racket                         # For SICP

    # Utilities
    autorandr                      # Create and Apply Display Profiles
    #bluez                          # Bluetooth Support for Linux
    #bluez-tools                    # Command Line Bluetooth Manager for Bluez5
    # easyeffects                   # useless without pipewire
    ffmpeg                         # Record, Convert, and Stream Audio and Video
    glxinfo                        # Info About OpenGL/Mesa
    mesa                           # OpenGL Library
    smartmontools                  # Get HDD SMART Information
    woeusb                         # Create Bootable USB Disks from Windows ISO Images
    xbindkeys                      # Launch Cmds with Keyboard or Mouse Button
    xvkbd                          # Virtual Keyboard Commands
  ];

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
          "DisplayPort-1" = "00ffffffffffff000472280601010101321a0104a53c22783bdcf1a655519d260e5054bfef8081c08140818090409500a940b300a9c0fc7e8088703812401820350056502100001e023a801871382d40582c450056502100001e000000fd003090b4b422010a202020202020000000fc00454432373320410a20202020200189020323f150010304050790121314161f2021223f40230907078301000065030c001000fe5b80a0703835403020350056502100001e866f80a0703840403020350056502100001e011d007251d01e206e28550056502100001e8c0ad08a20e02d10103e9600565021000018011d007251d01e206e28550056502100001e00004c";
          "DisplayPort-2" = "00ffffffffffff0010acbaa04c303635311c010380342078ea0495a9554d9d26105054a54b00714f8180a940d1c0d100010101010101283c80a070b023403020360006442100001e000000ff00434656394e3843353536304c0a000000fc0044454c4c2055323431350a2020000000fd00313d1e5311000a20202020202001a9020322f14f9005040302071601141f12132021222309070765030c00100083010000023a801871382d40582c450006442100001e011d8018711c1620582c250006442100009e011d007251d01e206e28550006442100001e8c0ad08a20e02d10103e960006442100001800000000000000000000000000000000000000000082";
        };
        config = {
          "DisplayPort-1" = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "144.00";
          };
          "DisplayPort-2" = {
            enable = true;
            crtc = 1;
            position = "1920x0";
            rotate = "right";
            mode = "1920x1200";
            rate = "60";
          };
        };
      };
    };
  };

}
