{ config, pkgs, lib, ... }:

{
  # User Programs
  home.packages = [
    pkgs.alacritty                  # Terminal Emulator
    pkgs.firefox                    # Web Browser
    pkgs.pavucontrol                # Audio Control Panel
    pkgs.arandr                     # Display Configuration Tool
    pkgs.autorandr                  # Create and Apply Display Profiles
    pkgs.mpv                        # Best Video Player
    pkgs.youtube-dl                 # Download Videos From YouTube & Other Sites
    pkgs.screenfetch                # System Information Tool
    pkgs.radeon-profile             # GUI Application to Set GPU Fan Curve
    pkgs.mesa                       # OpenGL Library
    pkgs.glxinfo                    # Info About OpenGL/Mesa
    pkgs.smartmontools              # Get HDD SMART Information
    pkgs.runelite                   # Old School Runescape
    pkgs.file                       # Standard UNIX Utility to Detect File Types
    pkgs.htop                       # Pretty and Interactive Process Viewer
    pkgs.signal-desktop             # Encrypted Messaging
    pkgs.xbindkeys                  # Launch Cmds with Keyboard or Mouse Button
    pkgs.xvkbd                      # Virtual Keyboard Commands
    pkgs.emacs-all-the-icons-fonts  # Doom Emacs Fonts
    pkgs.ripgrep                    # Doom Emacs Dependency
    pkgs.fd                         # Doom Emacs Dependency
    pkgs.nixfmt                     # Formatter for Nix Code
    pkgs.shellcheck                 # Script Analysis Tool
    pkgs.scrot                      # Simple Screenshot Tool
  ];

  # My IBM Model M Doesn't Have Super Key
  home.keyboard.layout = "dvorak";
  home.keyboard.options = [ "caps:super" ];

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
        bars = [ {
          fonts = [ "terminus 8" ]; # Statusbar Font
        } ];
      };
    };
    profileExtra = ''
      ${pkgs.autorandr}/bin/autorandr -c
      ${pkgs.xbindkeys}/bin/xbindkeys
    '';
  };

  # i3status config (enable this when home-manager updates)
  #programs.i3status-rust = {
  #  enable = true;
  #  bars.default.theme = "gruvbox-light";
  #};

  # PulseAudio System Tray
  services.pasystray.enable = true;

  # Network Manager Applet (enable this when you decide to switch)
  #services.network-manager-applet.enable = true;

  # My Cooler Master MM710 Preference
  home.file.".xbindkeysrc".text = ''
    "xvkbd -text "\[Left]""
      m:0x0 + b:8
    "xvkbd -text "\[Right]""
      m:0x0 + b:9
  '';

  # Emacs
  programs.emacs = {
    enable = true;
    extraPackages = (epkgs: [ epkgs.vterm ]);
  };

  # Configure Git
  programs.git = {
    enable = true;
    userEmail = "pnguyen4711@gmail.com";
    userName  = "Phillip Nguyen";
  };

  # Vim Settings
  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [ vim-airline vim-airline-themes nerdtree ];
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
      filetype plugin on
      filetype indent on

      " auto read when file in changed from outside buffer
      set autoread

      " sudo save file, good when write permission isn't given
      command W w !sudo tee % > /dev/null

      " set scrolloff (# of lines above/below cursor)
      set so=10

      " turn on wildmenu for filename completion in command mode
      set wildmenu
      set wildmode=longest,list,full
      set wildignore+=*.a,*.o
      set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png
      set wildignore+=.DS_Store,.git,.hg,.svn
      set wildignore+=*~,*.swp,*.tmp

      " basic UI fixes
      set ruler
      set cmdheight=1
      set laststatus=2 " see theme section for the statusline format

      " hide abandoned buffers
      set hid

      " backspace config
      set backspace=eol,start,indent
      set whichwrap+=<,>,h,l

      " make search good
      set hlsearch
      set incsearch

      " don't redraw when executing macros (good performance)
      set lazyredraw

      " regex magic
      set magic

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

      " linebreak on 100 chars
      set lbr
      set tw=500

      " 80 column marker (gray)
      highlight ColorColumn ctermbg=grey
      call matchadd('ColorColumn', '\%81v', 100)

      " wrap lines
      set wrap

      " Specify buffer behavior when switching between buffers
      try
        set switchbuf=useopen,usetab,newtab
        set stal=1
      catch
      endtry

      " return to last edit position when opening files
      autocmd BufReadPost *
          \ if line("'\"") > 0 && line("'\"") <= line("$") |
          \ exe "normal! g'\"" |
          \ endif

      " remember info about open buffers on close
      set viminfo^=%

      " mappings for moving between windows
      map <C-j> <C-W>j
      map <C-k> <C-W>k
      map <C-h> <C-W>h
      map <C-l> <C-W>l

      " make 0 work like it should
      map 0 ^

      " get rid of trailing white space on save
      autocmd BufWritePre * :%s/\s\+$//e

      " disable Background Color Erase (BCE) so that color schemes
      " render properly when inside 256-color tmux and GNU screen.
      if &term =~ '256color'
          set t_ut=
      endif

      " plugins
      let g:airline_powerline_fonts = 1
      if !exists('g:airline_symbols')
           let g:airline_symbols = {}
      endif
      let g:airline_theme='base16_google'
      let g:airline_symbols.space = " "
      let g:airline#extensions#tabline#enabled = 1
      '';
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
}
