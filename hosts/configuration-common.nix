{ config, pkgs, ... }:

{
  # Enable Flakes
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Automatic Garbage Collection of Nix Store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Save Space by Optimizing the Store (hardlink identical files)
  nix.settings.auto-optimise-store = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # NTFS support via FUSE
  boot.supportedFilesystems = [ "ntfs" ];

  # Set your time zone.
  time.timeZone = "America/Chicago";

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
    # This just handles all the dbus and systemd stuff automatically
    displayManager.gdm.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
    # Use home manager to configure window manager
    desktopManager.session = [
      {
        manage = "desktop";
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.xsession &
          waitPID=$!
        '';
      }
    ];
    desktopManager.wallpaper.mode = "scale";
  };

  # Enable CUPS to print documents
  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint pkgs.hplipWithPlugin ];
  };

  # Zeroconf Service to Locate Printer
  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  security.rtkit.enable = true;

  # Unfortunately zoom does not work with pipewire
  # services.pipewire ={
  #   enable = true;
  #   # package = pipewire;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # };

  # Ricing
  programs.dconf.enable = true;
  fonts.fonts = with pkgs; [
    # DejaVu fonts are already installed
    emacs-all-the-icons-fonts
    ibm-plex                           # has my favorite serif font
    iosevka                            # primary programming font
    (iosevka.override {                # secondary programming font
      set = "slab";
      privateBuildPlan = ''
        [buildPlans.iosevka-slab]
        family = "Iosevka Slab"
        spacing = "normal"
        serifs = "slab"
      '';
    })
    noto-fonts-cjk                     # for asian languages
    noto-fonts                         # for unicode coverage
    symbola                            # for more unicode coverage
    terminus_font                      # good bitmap font
  ];

  # Sorry Stallman Senpai
  nixpkgs.config.allowUnfree = true;

  # Security Settings
  security.protectKernelImage = true;
  security.pam.services.gdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?
}
