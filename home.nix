{ config, pkgs, lib, ... }:

{
  # User Programs
  home.packages = [
    # Does not include software enabled by options programs.* and services.*
    pkgs.adwaita-qt                     # Make Qt Apps Match GTK Apps
    pkgs.alacritty                      # Terminal Emulator
    pkgs.arandr                         # Display Configuration Tool
    pkgs.audacity                       # Audio Editor and Recording Software
    pkgs.autorandr                      # Create and Apply Display Profiles
    pkgs.brave                          # Privacy Browser
    pkgs.desmume                        # Nintendo DS Emulator
    pkgs.emacs-all-the-icons-fonts      # Doom Emacs Fonts
    pkgs.fd                             # Doom Emacs Dependency
    pkgs.file                           # Standard UNIX Utility to Detect File Types
    pkgs.firefox                        # Web Browser
    pkgs.glxinfo                        # Info About OpenGL/Mesa
    pkgs.htop                           # Pretty and Interactive Process Viewer
    pkgs.killall                        # Kill Processes by Name
    pkgs.mesa                           # OpenGL Library
    pkgs.networkmanager-openvpn         # NM Plugin for VPNs
    pkgs.networkmanagerapplet           # NM GUI for Taskbar
    pkgs.nixfmt                         # Formatter for Nix Code
    pkgs.pandoc                         # Universal Document Converter
    pkgs.papirus-icon-theme             # Pretty Icons
    pkgs.pavucontrol                    # Audio Control Panel
    pkgs.python3                        # Guido's Programming Language
    pkgs.qbittorrent                    # GUI Torrent Client
    pkgs.radeon-profile                 # GUI Application to Set GPU Fan Curve
    pkgs.ripgrep                        # Doom Emacs Dependency
    pkgs.runelite                       # Old School Runescape
    pkgs.screenfetch                    # System Information Tool
    pkgs.scrot                          # Simple Screenshot Tool
    pkgs.shellcheck                     # Script Analysis Tool
    pkgs.signal-desktop                 # Encrypted Messaging
    pkgs.smartmontools                  # Get HDD SMART Information
    pkgs.texlive.combined.scheme-full   # LaTeX Distribution
    pkgs.usbutils                       # Utils Like lsusb
    pkgs.xbindkeys                      # Launch Cmds with Keyboard or Mouse Button
    pkgs.xvkbd                          # Virtual Keyboard Commands
    pkgs.youtube-dl                     # Download Videos From YouTube & Other Sites
    pkgs.zathura                        # PDF/PS/DJVU/CB Viewer
  ];

  # My IBM Model M Doesn't Have Super Key
  home.keyboard.options = [ "caps:super" ];
  home.keyboard.layout = "dvorak, us";

  # Environment Variables
  home.sessionVariables = {
    QT_STYLE_OVERRIDE= "adwaita";
  };

  # Launch i3wm automatically from gdm
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = {
      enable = true;
      config = {
        modifier = "Mod4";          # Use Super/Windows Key Instead of Alt
        fonts = [ "terminus 8" ];   # Titlebar Font
        terminal = "alacritty";
        bars = [ ];                 # Use Polybar
        keybindings =
          let
            modifier = config.xsession.windowManager.i3.config.modifier;
          in lib.mkOptionDefault {
            "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun -icon-theme \"Papirus\" -show-icons";
            "${modifier}+grave" = "exec ${pkgs.rofi}/bin/rofi -show window -icon-theme \"Papirus\" -show-icons";
          };
        window.commands = [
          { # enable floating mode for all network manager windows
            criteria = {
              class = "Nm-connection-editor";
              instance = "nm-connection-editor";
            };
            command = "floating enable";
          }

          { # enable floating mode for firefox history/bookmarks menu
            criteria = {
              class = "Firefox";
              instance = "Places";
            };
            command = "floating enable";
          }
        ];
        startup = [ { command = "~/.reload_polybar.sh"; always = true; } ];
      };
    };
    profileExtra = ''
      ${pkgs.autorandr}/bin/autorandr -c
      ${pkgs.xbindkeys}/bin/xbindkeys
    '';
  };

  # Window Switcher + Run Dialog (dmenu replacement)
  programs.rofi = {
    enable = true;
    font = "DejaVu Sans 11";
    terminal = "alacritty";
    theme = "Paper";
  };

  #xsession.windowManager.bspwm = {
  #  enable = true;
  #  extraConfig = ''
  #  bspc monitor ^1 -d I II III IV V VI VII VIII IX X
  #  bspc monitor ^2 -d 1 2 3 4 5 6 7 8 9 10
  #  ''
  #};

  #services.sxhkd = {
  #  enable = true;
  #  # Prevents sxhkd from starting before keyboard layout is set
  #  extraOptions = [ "-m 1" ];
  #  keybindings = {
  #    # Exit BSPWM
  #    "super + shift + e" = "bspc quit";
  #    # Close Window
  #    "super + shift + q" = "bspc node --close";
  #    # Application Launcher
  #    "super + d" = "rofi -show drun -icon-theme \"Papirus\" -show-icons";
  #    # Window Switcher
  #    "super + tab" = "rofi -show window -icon-theme \"Papirus\" -show-icons";
  #    # Launch Terminal
  #    "super + Return" = "alacritty";
  #    # Toggle Window Floating Mode
  #    "super + space" = "bspc node --state \~floating";
  #    # Toggle Window Fullscreen Mode
  #    "super + f" = "bspc node --state \~fullscreen";
  #    # Toggle Window Tiling Mode
  #    "super + t" = "bspc node --state \~tiled";
  #    # Change Window Focus
  #    "super + {h,j,k,l}" = "bspc node --focus {west,south,north,east}";
  #    "super + {left,down,up,right}" = "bspc node -f {west,south,north,east}";
  #    # Swap Window With Direction
  #    "super + shift + {h,j,k,l}" = "bspc node --swap {west,south,north,east}";
  #    "super + shift + {left,down,up,right}" = "bspc node -s {west,south,north,east}";
  #    # Change Desktop Focus
  #    "super + {0-9}" = "bspc desktop --focus {0-9}";
  #    # Send Window to Desktop
  #    "super + shift + {0-9}" = "bspc node --to-desktop {0-9}";
  #    # Change Monitor Focus
  #    "super + grave" = "bspc monitor --focus next";
  #    # Send Window to Next Monitor
  #    "super + shift + grave" = "bspc node --to-monitor next";
  #    # Reload Simple X Hotkey Daemon
  #    "super + shift + r" = "pkill -USR1 -x sxhkd";
  #  };
  #};

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    config = {
      "bar/bottom" = {
        monitor = "\${env:MONITOR:}";
        bottom = true;
        font-0 = "terminus:size=11;0";
        enable-ipc = true;
        locale = "en_US.UTF8";
        tray-position = "right";
        tray-max-size = "12";
        padding-right = "1";
        padding-top = "1";
        scroll-up = "i3.prev";
        scroll-down = "i3.next";
        separator = " | ";
        modules-left = "i3";
        modules-right = "xkeyboard network vpn cpu memory date";
      };
      "module/cpu" = {
        type = "internal/cpu";
        label = "CPU %percentage%%";
      };
      "module/date" = {
        type = "internal/date";
        date = "%A %m-%d-%Y";
        time = "%H:%M:%S";
        label = "%date% %time%";
      };
      "module/i3" = {
        type = "internal/i3";
        pin-workspaces = true;
        label-focused-background = "#285577";
        label-focused-padding-right = "1";
        label-visible-background= "#5f676a";
        label-visible-padding-right = "1";
        label-unfocused-background = "#222222";
        label-unfocused-padding-right = "1";
        label-urgent-background = "#900000";
        label-urgent-padding-right = "1";
      };
      "module/xkeyboard" = {
        type = "internal/xkeyboard";
        format = "<label-layout>";
        label-layout = "%name%";
      };
      "module/memory" = {
        type = "internal/memory";
        label = "RAM %percentage_used%%";
      };
      "module/network" = {
        type = "internal/network";
        interface = "enp4s0";
        label-connected = "NET %ifname%";
        label-connected-foreground = "#00cc66";
        label-disconnected = "NET down";
        label-disconnected-foreground = "#ff3333";
      };
      "module/vpn" = {
        type = "custom/script";
        exec = ''if [[ $(ifconfig | grep tun0) ]]; then echo "%{F#00cc66}VPN ON"; else echo "%{F#ff3333}VPN OFF"; fi'';
      };
    };
    script = ""; # handle this in window manager
  };

  # Lightweight Notification Daemon
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.gnome3.adwaita-icon-theme;
      name = "Adwaita";
    };
    settings = {
      global = {
        font = "DejaVu Sans 11";
        follow = "keyboard";
        frame_width = "5";
        geometry = "300x5-30+50";
        icon_position = "left";
        idle_threshold = "300";
        markup = "yes";
        padding = "10";
        horizontal_padding = "10";
        shrink = "yes";
        separator_color = "frame";
        show_indications = "false";
        word_wrap = true;
      };
      urgency_low = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#4c7899";
        timeout = "10";
      };
      urgency_normal = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#4c7899";
        timeout = "10";
      };
      urgency_critical = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#e00000";
        timeout = "0";
      };
    };
  };

  # Automatically Put Polybar On Each Monitor
  # Launch from window manager startup file
  home.file.".reload_polybar.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      polybar-msg cmd quit
      for m in $(polybar --list-monitors | cut -d":" -f1); do
          MONITOR=$m polybar --reload bottom &
      done
    '';
  };

  # Screensaver and Screen Locking Settings
  services.xscreensaver = {
    enable = true;
    settings = {
      timeout = 30;        # Activate when idle for 30 minutes
      cycle = 5;           # Change screensavers every 5 minutes
      lock = true;         # Ask for user password to reenter
      lockTimeout = 30;    # Lock after (total) 60 minutes idle
      dpmsEnabled = true;  # Enable display power management
      dpmsSuspend = 180;   # Go into power saving mode after 3 hours
    };
  };

  # PulseAudio System Tray Applet
  services.pasystray.enable = true;

  # Network Manager System Tray Applet
  services.network-manager-applet.enable = true;

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
          "DVI-D-1" = "00ffffffffffff00047228060e0c1084291c0103803c22782a9055a75553a028135054b36c00714f818081c081009500b300d1c00101023a801871382d40582c450056502100001e000000ff0054394441413030333339303000000000fd0030901ea021000a202020202020000000fc00454432373320410a202020202001df02030700421890fb7e8088703812401820350056502100001e1a1d008051d01c204080350056502100001c866f80a0703840403020350056502100001e023a801871382d40582c450056502100001e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000012";
          "HDMI-A-0" = "00ffffffffffff004c2dfe080000000029150103801009780aee91a3544c99260f5054bdef80714f81c0810081809500a9c0b3000101023a801871382d40582c4500a05a0000001e662156aa51001e30468f3300a05a0000001e000000fd00184b0f5117000a202020202020000000fc0053414d53554e470a2020202020011d02031ff147900405032022072309070783010000e2000f67030c001000b82d011d8018711c1620582c2500a05a0000009e011d007251d01e206e285500a05a0000001e8c0ad08a20e02d10103e9600a05a00000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000d6";
        };
        config = {
          "DVI-D-1" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "60.00";
          };
          "HDMI-A-0" = {
            enable = true;
            mode = "1920x1080";
            position = "1920x0";
            rate = "60.00";
          };
        };
      };
    };
  };

  # Emacs
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: [ epkgs.vterm epkgs.emojify ]);
  };

  # Default Git User
  programs.git = {
    enable = true;
    userEmail = "pnguyen4711@gmail.com";
    userName  = "Phillip Nguyen";
  };

  # The Best Video Player
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      video-sync = "display-resample";
      interpolation = true; # not motion interpolation
      tscale = "oversample";
    };
  };

  # Terminal Settings
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        size = 12;
        normal.family = "terminus";
        italic.family = "terminus";
        bold.family   = "terminus";
      };
      # Solarized Light Theme
      colors = {
        primary = {
          background = "#fdf6e3";
          foreground = "#657b83";
        };
        cursor = {
          text   = "#fdf6e3";
          cursor = "#657b83";
        };
        normal = {
          black   = "#073642";
          red     = "#dc322f";
          green   = "#859900";
          yellow  = "#b58900";
          blue    = "#268bd2";
          magenta = "#d33682";
          cyan    = "#2aa198";
          white   = "#eee8d5";
        };
        bright = {
          black   = "#002b36";
          red     = "#cb4b16";
          green   = "#586e75";
          yellow  = "#657b83";
          blue    = "#839496";
          magenta = "#6c71c4";
          cyan    = "#93a1a1";
          white   = "#fdf6e3";
        };
      };
    };
  };

  # Vim Settings
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes ];
    settings = {
      history = 700;     # Undo Limit
      number = true;     # Line Numbers
      expandtab = true;  # Convert Tabs to Spaces
      tabstop = 4;       # Width of Tab Character
      shiftwidth = 4;    # Indent With 4 Spaces When Shifting Lines
      ignorecase = true; # Search Option
      smartcase = true;  # Case Sensitive When Search Contains Uppercase Letter
    };
    extraConfig =
      ''
      " Enable filetype plugins
      filetype plugin indent on

      " auto read when file in changed from outside buffer
      set autoread

      " sudo save file, good when write permission isn't given
      command W w !sudo tee % > /dev/null

      " set scrolloff (# of lines above/below cursor)
      set so=10

      " basic UI fixes
      set ruler
      set laststatus=2 " display statusline always

      " hide abandoned buffers
      set hidden

      " backspace config
      set backspace=eol,start,indent

      " automatically move to next line after reaching
      " first/last character in line (only normal mode)
      set whichwrap+=<,>,h,l

      " make search good
      set hlsearch
      set incsearch

      " don't redraw when executing macros (good performance)
      set lazyredraw

      " Show matching brackets on indicator hover
      set showmatch
      set mat=2

      " no bleeping bleeps!
      set noerrorbells
      set novisualbell

      " enable syntax highlighting
      syntax enable
      autocmd BufEnter * :syntax sync fromstart

      " why isn't this universal yet?
      set encoding=utf8
      set ffs=unix,dos,mac

      " no backups, no swap file(s) mess
      set nobackup
      set nowb
      set noswapfile

      " tab config, commence holy war
      set smarttab

      " auto and smart indent
      set ai
      set si

      " wrap lines
      set wrap

      " get rid of trailing white space on save
      autocmd BufWritePre * :%s/\s\+$//e

      " plugins
      let g:airline_powerline_fonts = 1
      if !exists('g:airline_symbols')
          let g:airline_symbols = {}
      endif
      let g:airline_symbols.space = " "
      let g:airline_theme='base16_google'
      let g:airline#extensions#tabline#enabled = 1
      '';
  };
}
