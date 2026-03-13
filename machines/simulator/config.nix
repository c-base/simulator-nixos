{
  config,
  pkgs,
  nixpkgs-unstable,
  selfpkgs,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader = {
    systemd-boot = {
      enable = true;
      windows."11".efiDeviceHandle = "HD0b";
      #edk2-uefi-shell.enable = true;
    };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelPackages = pkgs.linuxPackages_6_18;
  networking.hostName = "simulator"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "de,us";
      options = "eurosign:e,caps:escape,grp:win_space_toggle";
    };
  };

  # Configure console keymap
  console.keyMap = "de";

  services.pipewire = {
    enable = true;
    systemWide = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.monado = {
    enable = true;
    defaultRuntime = true;
  };
  systemd.user.services."monado".environment = {
    XRT_COMPOSITOR_COMPUTE = "1";
    XRT_DEBUG_GUI = "1";
    STEAMVR_LH_ENABLE = "1";
    LH_STANDBY_ON_EXIT = "1";
  };
  home-manager.users.alien = {
    home.file = {
      ".local/share/monado/hand-tracking-models".source = pkgs.fetchgit {
        url = "https://gitlab.freedesktop.org/monado/utilities/hand-tracking-models.git";
        fetchLFS = true;
        sha256 = "sha256-x/X4HyyHdQUxn3CdMbWj5cfLvV7UyQe1D01H93UCk+M=";
      };
    };
    xdg.configFile = {
      # to use the correct openvr comp prepend: "PRESSURE_VESSEL_FILESYSTEMS_RW=$XDG_RUNTIME_DIR/monado_comp_ipc"
      "openvr/openvrpaths.vrpath".text = ''
        {
          "config": [
            "${config.home-manager.users.alien.xdg.dataHome}/Steam/config"
          ],
          "external_drivers" : null,
          "jsonid": "vrpathreg",
          "log": [
            "${config.home-manager.users.alien.xdg.dataHome}/Steam/logs"
          ],
          "runtime": [
            "${nixpkgs-unstable.opencomposite}/lib/opencomposite"
          ],
          "version" : 1
        }
      '';
      "openxr/1/active_runtime.json".source =
        config.environment.etc."xdg/openxr/1/active_runtime.json".source;
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.alien = {
    isNormalUser = true;
    description = "Alien";
    extraGroups = [
      "networkmanager"
      "wheel"
      "pipewire"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Install firefox.
  programs = {
    firefox.enable = true;
    partition-manager.enable = true;
    steam = {
      enable = true;
      extraPackages = [
        # So we don't have that ugly cursor when hovering over Steam
        pkgs.kdePackages.breeze
      ];
      extraCompatPackages = [
        nixpkgs-unstable.proton-ge-rtsp-bin
        nixpkgs-unstable.proton-ge-bin
      ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cifs-utils
    vim
    wget
    htop
    btop
    gnumake
    git
    bash
    python3

    selfpkgs.overte-vr-appimage
    nixpkgs-unstable.wayvr
  ];

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}
