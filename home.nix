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
  home.packages = with pkgs; [
    # Does not include software enabled by options programs.* and services.*
    alacritty                      # Terminal Emulator
    arandr                         # Display Configuration Tool
    audacity                       # Audio Editor and Recording Software
    autorandr                      # Create and Apply Display Profiles
    #bluez                          # Bluetooth Support for Linux
    #bluez-tools                    # Command Line Bluetooth Manager for Bluez5
    brave                          # Privacy Browser
    cmake                          # Cross-Platform Makefile Generator
    darktable                      # Virtual Lighttable and Darkroom for Photographers
    desmume                        # Nintendo DS Emulator
    discord                        # Voice and Text Chat for Gamers
    # easyeffects                   # useless without pipewire
    exfatprogs                     # exFAT filesystem userspace utilities
    fd                             # Doom Emacs Dependency
    file                           # Standard UNIX Utility to Detect File Types
    ffmpeg                         # Record, Convert, and Stream Audio and Video
    gcc                            # GNU Compiler Collection
    gimp                           # The GNU Image Manipulation Program
    glxinfo                        # Info About OpenGL/Mesa
    gnumake                        # Build Automation Tool
    gnome.file-roller              # GUI Archive Management Utility
    htop                           # Pretty and Interactive Process Viewer
    killall                        # Kill Processes by Name
    libarchive                     # Multi-format Archive and Compression Library
    libsForQt5.kdenlive            # Video Editor
    libgccjit                      # API for embedding GCC inside programs
    libtool                        # Generic Library Support Script
    libreoffice-fresh
    melonDS                        # WIP Nintendo DS Emulator
    mesa                           # OpenGL Library
    networkmanager-openvpn         # NM Plugin for VPNs
    networkmanagerapplet           # NM GUI for Taskbar
    nixfmt                         # Formatter for Nix Code
    unstable.nyxt
    obs-studio                     # Video Recording and Live Streaming Software
    p7zip                          # Utility for 7z archives
    pandoc                         # Universal Document Converter
    papirus-icon-theme             # Pretty Icons
    pavucontrol                    # Audio Control Panel
    postman
    python-with-my-packages        # Guido's Programming Language WITH packages in path
    nodePackages.pyright           # For Doom Emacs Python LSP Support
    nodePackages.typescript        # Better Javascript
    nodePackages.nodemon
    nodePackages.vscode-langservers-extracted # For Doom Emacs HTML/CSS LSP Support
    nodePackages.typescript-language-server   # For Doom Emacs Javascript LSP Support
    nodejs
    qbittorrent                    # GUI Torrent Client
    racket                         # For SICP
    ripgrep                        # Doom Emacs Dependency
    unrar                          # Utility for RAR Archives
    runelite                       # Old School Runescape
    screenfetch                    # System Information Tool
    scrot                          # Simple Screenshot Tool
    shellcheck                     # Script Analysis Tool
    signal-desktop                 # Encrypted Messaging
    slack                          # Corporate IRC
    smartmontools                  # Get HDD SMART Information
    texlive.combined.scheme-full   # LaTeX Distribution
    unzip                          # Extraction Utility for Zip Archives
    usbutils                       # Utils Like lsusb
    vlc                            # Personally, just for CD/DVD playback
    volctl                         # Per-application tray icon volume control
    vscode
    woeusb                         # Create Bootable USB Disks from Windows ISO Images
    xbindkeys                      # Launch Cmds with Keyboard or Mouse Button
    xclip                          # For emacs everywhere
    xdotool                        # For emacs everywhere
    xfce.thunar                    # File manager, cuz it get annoying not having one
    xfce.tumbler                   # Enables thumbnails
    xorg.xev                       # Prints Contents of X Events for Debugging
    xorg.xprop                     # For emacs everywhere
    xorg.xwininfo                  # For emacs everywhere
    xournalpp                      # Edit and Annotate PDFs
    xvkbd                          # Virtual Keyboard Commands
    yt-dlp                         # Download Videos From YouTube & Other Sites
    zathura                        # PDF/PS/DJVU/CB Viewer
    zip                            # Compressor/Archiver
    zoom-us                        # Ugh.
  ];

  # My IBM Model M Doesn't Have Super Key
  home.keyboard.options = [ "caps:super" ];
  home.keyboard.layout = "dvorak, us";

  # Get Uniform Look Between GTK and QT Programs
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = {
      name = "adwaita";
      package = pkgs.adwaita-qt;
    };
  };

  # Launch i3wm automatically from gdm
  home.file.".xinitrc".source = config.lib.file.mkOutOfStoreSymlink "/home/user/.xsession";
  xsession = {
    enable = true;
    #scriptPath = ".hm-xsession";
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = {
        modifier = "Mod4";                     # Use Super Key Instead of Alt
        fonts = {                              # Titlebar Font
          names = [ "Iosevka Slab Extended" ];
          size = 9.0;
        };
        colors = {
          focused = {
            background  = "#285577";           # default
            border      = "#4c7899";           # default
            childBorder = "#4f7ca9";           # new color
            indicator   = "#2e9ef4";           # default
            text        = "#ffffff";           # default
          };
        };
        gaps = {
          inner = 12;
          outer = 3;
          smartGaps = true;
        };
        terminal = "alacritty";
        bars = [ ];                            # Use Polybar
        keybindings =
          let
            modifier = config.xsession.windowManager.i3.config.modifier;
          in lib.mkOptionDefault {
            "${modifier}+d" = "exec ${pkgs.rofi}/bin/rofi -show drun";
            "${modifier}+Tab" = "exec ${pkgs.rofi}/bin/rofi -show window";
            "${modifier}+Control+e" = "exec emacsclient --eval \"(emacs-everywhere)\"";
          };
        window = {
          border = 5;
          titlebar = false;
          hideEdgeBorders = "smart";
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

          { # enable floating mode for all Microsoft Teams notifications
            criteria = {
              title = "Microsoft Teams Notification";
            };
            command = "floating enable";
          }

          { # enable floating mode for all Zoom Popups
            criteria = {
              title = "^zoom$";
              class = "[zoom]*";
            };
            command = "floating enable";
          }
        ];
        workspaceOutputAssign = [
          # My preferred scheme is to have odd numbered workspaces on
          # left monitor counting up and even numbered workspaces on
          # right monitor counting down. Don't know why, but it works.
          {
            output = "DisplayPort-1";
            workspace = "1";
          }

          {
            output = "DisplayPort-2";
            workspace = "10";
          }
        ];
        startup = [
          {
            command = "~/.reload_polybar.sh";
            always = true;
            notification = false;  # equal to --no-startup-id parameter
          }

          {
            command = "volctl";
            notification = false;  # equal to --no-startup-id parameter
          }
        ];
      };
    };
    profileExtra = ''
      ${pkgs.autorandr}/bin/autorandr -c
      ${pkgs.xbindkeys}/bin/xbindkeys
    '';
  };

  # Dim Blue Light For Sleep Hygiene
  services.redshift = {
    enable = true;
    tray = true;
    temperature.day = 6500;
    provider = "manual";
    latitude = 36.17;
    longitude = -86.76;
  };

  # Window Switcher + Run Dialog (dmenu replacement)
  programs.rofi = {
    enable = true;
    extraConfig = {
      icon-theme = "Papirus";
      modi = "drun,window";
      show-icons = true;
    };
    font = "IBM Plex Sans 11";
    terminal = "alacritty";
    theme = "Paper";
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
        format = "<b>%s</b>\n%b";
        frame_width = 5;
        geometry = "300x5-30+50";
        icon_position = "left";
        idle_threshold = 300;
        markup = "yes";
        max_icon_size = 64;
        padding = 10;
        horizontal_padding = 10;
        shrink = "yes";
        separator_color = "frame";
        show_indicators = "no";
        word_wrap = true;
      };
      urgency_low = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#4c7899";
        timeout = 10;
      };
      urgency_normal = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#4c7899";
        timeout = 10;
      };
      urgency_critical = {
        background = "#202020";
        foreground = "#fffff8";
        frame_color = "#e00000";
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
      cycle = 5;           # Change screensavers every 5 minutes
      dpmsEnabled = true;  # Enable display power management
      dpmsSuspend = 180;   # Go into power saving mode after 3 hours
      lock = true;         # Ask for user password to reenter
      lockTimeout = 120;   # Lock after (total) 2 hours idle
      timeout = 60;        # Activate when idle for 1 hour
    };
  };

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

  # Emacs
  programs.emacs = {
    enable = true;
    #package = pkgs.emacsNativeComp; # use emacs from overlay
    # Packages That Require Compiling Some (non-elisp) Component
     extraPackages = (epkgs: [
       epkgs.vterm
       epkgs.emojify
       epkgs.pdf-tools
     ]);
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
      interpolation = true; # not motion interpolation
      profile = "gpu-hq";
      tscale = "oversample";
      video-sync = "display-resample";
    };
    # package = pkgs.mpv-unwrapped.override {
    #   cddaSupport = true;
    # };
  };

  # Terminal Settings
  programs.alacritty = {
    enable = true;
    settings = {
      font = {
        bold.family   = "terminus";
        italic.family = "terminus";
        normal.family = "terminus";
        size = 12;
      };
      # Uber High-Contrast Light Theme
      colors = {
        primary = {
          foreground = "#000000";
          background = "#ffffff";
        };
        normal = {
          black   = "#000000";
          red     = "#990000";
          green   = "#00A600";
          yellow  = "#999900";
          blue    = "#0000B2";
          magenta = "#B200B2";
          cyan    = "#00A6B2";
          white   = "#BFBFBF";
        };
        bright = {
          black   = "#666666";
          red     = "#E50000";
          green   = "#00D900";
          yellow  = "#E5E500";
          blue    = "#0000FF";
          magenta = "#E500E5";
          cyan    = "#00E5E5";
          white   = "#E5E5E5";
        };
      };
    };
  };

  # Vim Settings
  programs.vim = {
    enable = true;
    settings = {
      expandtab = true;  # Convert Tabs to Spaces
      history = 700;     # Undo Limit
      hidden = true;     # Hide Abandoned Buffers
      ignorecase = true; # Search Option
      number = true;     # Line Numbers
      shiftwidth = 4;    # Indent With 4 Spaces When Shifting Lines
      smartcase = true;  # Case Sensitive When Search Contains Uppercase Letter
      tabstop = 4;       # Use this many spaces for tab
    };
    extraConfig = ''
      autocmd BufWritePre * :%s/\s\+$//e   " get rid of trailing white space on save
      command W w !sudo tee % > /dev/null  " sudo save file
      filetype plugin indent on            " enable filetype plugins
      set autoread                         " auto read when file in changed elswhere
      set so=10                            " # of lines above/below cursor
      set ruler                            " display row,col
      set laststatus=2                     " display statusline always
      set backspace=eol,start,indent       " backspace config
      set hlsearch                         " make search good
      set incsearch
      set lazyredraw                       " don't redraw when executing macros
      set showmatch                        " show matching brackets on indicator hover
      set mat=2
      set noerrorbells                     " no bleeping bleeps!
      set novisualbell
      set encoding=utf8                    " why isn't this universal yet?
      set ffs=unix,dos,mac
      set nobackup                         " no backups, no swap file(s) mess
      set nowb
      set noswapfile
      set smarttab                         " tab config, commence holy war
      set ai                               " auto and smart indent
      set si
      set whichwrap+=<,>,h,l               " go to next/prev line after passing start/end
      set wrap                             " wrap lines
    '';
  };

  programs.firefox = {
    enable = true;
    # Install just the bare basics to get going. Install the rest normally.
    # These are disabled by default. Remember to manually enable them.
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      decentraleyes
      greasemonkey
      https-everywhere
      privacy-badger
      tree-style-tab
      ublock-origin
    ];
    profiles."default" = {
      # Any settings modified from within firefox are overriden on next launch
      settings = {
        "accessibility.force_disabled" = 1;
        "app.shield.optoutstudies.enabled" = false;             # not participating
        "app.normandy.enabled" = false;                         # don't let mozilla change settings
        "browser.aboutConfig.showWarning" = false;              # I generally know what I'm doing
        "browser.contentblocking.category" = "strict";          # "enhanced tracking protection"
        "browser.cache.disk.enable" = false;                    # makes my hard drive LOUD
        "browser.cache.disk_cache_ssl" = false;                 # disable cache for ssl connections
        "browser.cache.offline.enable" = false;                 # offline means offline!
        "browser.formfill.enable" = false;                      # disable saving form form data
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.topSitesRows" = 3;
        "browser.ping-centre.telemetry" = false;
        "browser.toolbars.bookmarks.visibility" = "never";      # just use bookmarks manager
        "browser.search.widget.inNavBar" = true;                # enable separate search bar
        "browser.uidensity" = 1;                                # compact ui
        "browser.urlbar.speculativeConnect.enabled" = false;    # don't preload autocomplete URLs
        "browser.urlbar.suggest.searches" = false;              # disable suggestions in url bar
        "browser.sessionstore.interval" = 200000;               # save stuff less often: 15s -> 5m
        "browser.sessionstore.privacy_level" = 2;               # reduce save/restore granularity
        "datareporting.healthreport.uploadEnabled" = false;     # send less stuff to mozilla
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "extensions.formautofill.addresses.enabled" = false;    # no ask/remember/autofill
        "extensions.formautofill.creditCards.enabled" = false;  # no ask/remember/autofill
        "extensions.pocket.enabled" = false;                    # get this shit away from me
        "extensions.pocket.onSaveRecs" = false;                 # "                        "
        "extensions.pocket.site" = "";                          # "                        "
        "extensions.pocket.api" = "";                           # "                        "
        "font.language.group" = "x-western";
        "font.name.monospace.ja" = "Noto Sans CJK JP";
        "font.name.monospace.x-western" = "IBM Plex Mono";
        "font.name.sans-serif.ja" = "Noto Sans CJK JP";
        "font.name.sans-serif.x-western" = "IBM Plex Sans";
        "font.name.serif.ja" = "Noto Sans CJK JP";
        "font.name.serif.x-western" = "IBM Plex Serif";
        "geo.enabled" = false;                                  # disable geolocation
        "gfx.font_rendering.graphite.enabled" = false;          # disable smart font system
        "media.peerconnection.enabled" = false;                 # disables WebRTC
        "media.navigator.enabled" = false;                      # "                        "
        "network.dnsCacheEntries" = 100;
        "network.dns.disablePrefetch" = true;                   # no prefetching
        "network.http.speculative-parallel-limit" = 0;          # disable prefetch link on hover
        "network.http.referer.trimmingPolicy" = 2;              # only send origin in referrer header
        "network.http.referer.XOriginTrimmingPolicy" = 2;       # "                                 "
        "network.IDN_show_punycode" = true;                     # prevent unicode-based phishing
        "network.predictor.enabled" = false;                    # disable prefetching
        "network.prefetch-next" = false;                        # disable link prefetching
        "privacy.donottrackheader.enabled" = true;              # probably useless
        "privacy.firstparty.isolate" = true;                    # seperates site cookies
        "privacy.trackingprotection.enabled" = true;            # probably useless
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.resistFingerprinting" = true;
        "signon.rememberSignons" = false;                       # don't ask/remember passwords
        "startup.homepage_welcome_url" = "";                    # prevent unnecessary phoning home
        "startup.homepage_welcome_url.additional" = "";         # "                              "
        "startup.homepage_override_url" = "";                   # "                              "
        "system.rsexperimentloader.enabled" = false;            # disable new feature experiments
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;  # use userChrome.css
        "toolkit.telemetry.enabled" = false;                           # disable telemetry
        "toolkit.telemetry.archive.enabled" = false;                   # "               "
        "toolkit.telemetry.firstShutdownPing.enabled" = false;         # "               "
        "toolkit.telemetry.newProfilePing.enabled" = false;            # "               "
        "toolkit.telemetry.server" = "";                               # "               "
        "toolkit.telemetry.shutdownPingSender.enabled" = false;        # "               "
        "toolkit.telemetry.unified" = false;                           # "               "
        "toolkit.telemetry.updatePing.enabled" = false;                # "               "
        "webgl.disabled" = true;                                       # webgl is insecure
      };
      userChrome = ''
        /* hides the native tabs */
        #TabsToolbar {
          visibility: collapse !important;
        }
      '';
    };
  };
  home.stateVersion = "22.05";
}
