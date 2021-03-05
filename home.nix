{ config, pkgs, lib, ... }:

with import <nixpkgs> {
  config.allowUnfree = true;
};
let my-python-packages = python-packages: with python-packages; [
      # (import ./personal-repo/cs202.nix)
      matplotlib              # plotting library
      numpy                   # numerical python for data science
      pybullet                # Physics Engine for Robot Simulation
      pyflakes                # For Doom Emacs Python Linting
      pytest                  # Framework for Writing Python Tests
      python-language-server  # For Doom Emacs Python LSP Support
    ];
    python-with-my-packages = python3.withPackages my-python-packages;
in
{
  # User Programs
  home.packages = [
    # Does not include software enabled by options programs.* and services.*
    adwaita-qt                     # Make Qt Apps Match GTK Apps
    alacritty                      # Terminal Emulator
    audacity                       # Audio Editor and Recording Software
    brave                          # Privacy Browser
    cmake                          # Cross-Platform Makefile Generator
    desmume                        # Nintendo DS Emulator
    discord                        # Voice and Text Chat for Gamers
    emacs-all-the-icons-fonts      # Doom Emacs Fonts
    fd                             # Doom Emacs Dependency
    file                           # Standard UNIX Utility to Detect File Types
    firefox                        # Web Browser
    gcc                            # GNU Compiler Collection
    gimp                           # The GNU Image Manipulation Program
    glxinfo                        # Info About OpenGL/Mesa
    gnumake                        # Build Automation Tool
    htop                           # Pretty and Interactive Process Viewer
    killall                        # Kill Processes by Name
    libtool                        # Generic Library Support Script
    mesa                           # OpenGL Library
    nixfmt                         # Formatter for Nix Code
    obs-studio                     # Video Recording and Live Streaming Software
    pandoc                         # Universal Document Converter
    pavucontrol                    # Audio Control Panel
    python-with-my-packages        # Guido's Programming Language WITH packages in path
    qbittorrent                    # GUI Torrent Client
    radeon-profile                 # GUI Application to Set GPU Fan Curve
    ripgrep                        # Doom Emacs Dependency
    runelite                       # Old School Runescape
    screenfetch                    # System Information Tool
    scrot                          # Simple Screenshot Tool
    shellcheck                     # Script Analysis Tool
    signal-desktop                 # Encrypted Messaging
    slack                          # Corporate IRC
    smartmontools                  # Get HDD SMART Information
    teams                          # Microsoft Teams
    texlive.combined.scheme-full   # LaTeX Distribution
    unzip                          # Extraction Utility for Zip Archives
    usbutils                       # Utils Like lsusb
    xorg.xev                       # Prints Contents of X Events for Debugging
    youtube-dl                     # Download Videos From YouTube & Other Sites
    zathura                        # PDF/PS/DJVU/CB Viewer
    zip                            # Compressor/Archiver
  ];

  # My IBM Model M Doesn't Have Super Key
  home.keyboard.options = [ "caps:super" ];
  home.keyboard.layout = "dvorak, us";

  # Environment Variables
  home.sessionVariables = {
    QT_STYLE_OVERRIDE = "adwaita";
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
      interpolation = true; # not motion interpolation
      profile = "gpu-hq";
      tscale = "oversample";
      video-sync = "display-resample";
    };
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
      # Solarized Light Theme
      colors = {
        cursor = {
          text   = "#fdf6e3";
          cursor = "#657b83";
        };
        bright = {
          black   = "#002b36";
          blue    = "#839496";
          cyan    = "#93a1a1";
          green   = "#586e75";
          magenta = "#6c71c4";
          red     = "#cb4b16";
          white   = "#fdf6e3";
          yellow  = "#657b83";
        };
        normal = {
          black   = "#073642";
          blue    = "#268bd2";
          cyan    = "#2aa198";
          green   = "#859900";
          magenta = "#d33682";
          red     = "#dc322f";
          white   = "#eee8d5";
          yellow  = "#b58900";
        };
        primary = {
          background = "#fdf6e3";
          foreground = "#657b83";
        };
      };
    };
  };

  # Vim Settings
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes ];
    settings = {
      expandtab = true;  # Convert Tabs to Spaces
      history = 700;     # Undo Limit
      ignorecase = true; # Search Option
      number = true;     # Line Numbers
      shiftwidth = 4;    # Indent With 4 Spaces When Shifting Lines
      smartcase = true;  # Case Sensitive When Search Contains Uppercase Letter
      tabstop = 4;       # Width of Tab Character
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
