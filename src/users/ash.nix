{ config, pkgs, lib, ... }:

let
  inherit (config.local) share;
  cfg = config.local.users.ash;
in lib.mkIf cfg.enable {
  # Hacky workaround of issue 948 of home-manager
  systemd.services.home-manager-ash.preStart = ''
    ${pkgs.nix}/bin/nix-env -i -E
  '';

  # System level baasic config for user.
  users.users.ash = {
    hashedPassword =
      "$6$FAs.ZfxAkhAK0ted$/aHwa39iJ6wsZDCxoJVjedhfPZ0XlmgKcxkgxGDE.hw3JlCjPHmauXmQAZUlF8TTUGgxiOJZcbYSPsW.QBH5F.";
    shell = pkgs.zsh;
    isNormalUser = true;
    # wheel - sudo
    # networkmanager - manage network
    # video - light control
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  # Install packages to `/etc/profile` because upstream would default it in the future.
  home-manager.useUserPackages = true;

  # Home-manager settings. It would be much more powerful and specific than above.
  home-manager.users.ash = {
    # User-layer packages
    home.packages = with pkgs;
      [
        hunspell
        hunspellDicts.en-us-large
        emacs
        i3lock
        xss-lock
        xautolock
        escrotum
        dmenu
        libnotify
        gnome3.file-roller
        gnome3.nautilus
        gnome3.eog
        evince
      ] ++ cfg.extraPackages;

    # Fontconfig
    fonts.fontconfig.enable = true;

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = "eog.desktop"; # `.jpg`
        "application/pdf" = "org.gnome.Evince.desktop"; # `.pdf`
      };
    };

    # Package settings
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font = {
            normal = {
              family = "Fira Code Retina";
              style = "Regular";
            };
          };
          env = { WINIT_HIDPI_FACTOR = toString share.scale; };
        };
      };
      # GnuPG
      gpg = {
        enable = true;
        settings = { throw-keyids = false; };
      };

      # Git
      git = {
        enable = true;
        userName = "Harry Ying";
        userEmail = "lexugeyky@outlook.com";
        signing = {
          signByDefault = true;
          key = "0xAE53B4C2E58EDD45";
        };
        extraConfig = { credential = { helper = "store"; }; };
      };

      # zsh
      zsh = {
        enable = true;
        # This would make C-p, C-n act exactly the same as what up/down arrows do.
        initExtra = ''
          bindkey "^P" up-line-or-search
          bindkey "^N" down-line-or-search
        '';
        # NOTE: We don't use the sessionVar option provided by home-manager, because the former one only make it available in zshrc. We need env vars everywhere.
        # GDK_SCALE: Scale the whole UI for GTK applications
        # GDK_DPI_SCALE: Scale the fonts back for GTK applications to avoid double scaling
        # QT_AUTO_SCREEN_SCALE_FACTOR: Let QT auto detect the DPi
        envExtra = ''
          export GDK_SCALE=${toString share.scale}
          export GDK_DPI_SCALE=${toString (1.0 / share.scale)}
          export QT_AUTO_SCREEN_SCALE_FACTOR=1
        '';
        defaultKeymap = "emacs";
        oh-my-zsh = {
          enable = true;
          theme = "agnoster";
          plugins = [ "git" ];
        };
      };
    };

    # Handwritten configs
    home.file = {
      ".config/gtk-3.0/settings.ini".source =
        (share.dirs.dotfiles + /ash/gtk-settings.ini);
      ".emacs.d/init.el".source = (share.dirs.dotfiles + /ash/emacs.d/init.el);
      ".emacs.d/elisp/".source = (share.dirs.dotfiles + /ash/emacs.d/elisp);
    };

    # Dconf settings
    dconf.settings = {
      "desktop/ibus/general/hotkey" = {
        triggers = [ "<Control><Shift>space" ];
      };
    };
  };
}
