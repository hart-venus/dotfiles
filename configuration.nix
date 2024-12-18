{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix
  ];

  # Bash aliases
  programs.bash.shellAliases = {
    cd = "z";
  };
  # Enable docker

  services.mullvad-vpn.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  programs.direnv.enable = true;
  # NVIDIA SETUP
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];
  networking.firewall.allowedTCPPorts = [3389];
  networking.firewall.allowedUDPPorts = [3389];
  hardware.opentabletdriver.enable = false; # buggy
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;

    nvidiaSettings = true;
    prime.sync.enable = true;

    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
  };

  services.xserver = {
    layout = "us, latam";
    xkbOptions = "grp:ctrl_space_toggle, ctrl:swapcaps";
  };

  console.useXkbConfig = true;

  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  networking.hostName = "pavilion"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  nix.settings.experimental-features = ["nix-command" "flakes"];
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # Testing two: The testing Continues

  # Enable networking
  networking.networkmanager.enable = true;
  time.timeZone = "America/Costa_Rica";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_CR.UTF-8";
    LC_IDENTIFICATION = "es_CR.UTF-8";
    LC_MEASUREMENT = "es_CR.UTF-8";
    LC_MONETARY = "es_CR.UTF-8";
    LC_NAME = "es_CR.UTF-8";
    LC_NUMERIC = "es_CR.UTF-8";
    LC_PAPER = "es_CR.UTF-8";
    LC_TELEPHONE = "es_CR.UTF-8";
    LC_TIME = "es_CR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.excludePackages = [pkgs.xterm];
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-terminal
    pantheon.epiphany
    gnome-console
  ];

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "hart" = import ./home.nix;
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  programs.openvpn3.enable = true;
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hart = {
    isNormalUser = true;
    description = "Ariel Leyva";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Add zram
  zramSwap.enable = true;
  # Install firefox.
  programs.firefox.enable = true;
  # Install steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    libsForQt5.qt5.qtwayland
    freerdp3
    pkgs-unstable.gleam
    pkgs-unstable.erlang_27
    pkgs-unstable.rebar3
    inotify-tools
    pkgs-unstable.xwaylandvideobridge
    pkgs-unstable.zed-editor.fhs
    go
    xsel
    google-chrome
    julia_19-bin
    amberol
    obsidian
    normcap
    jq
    qutebrowser
    cowsay
    lf
    godot_4
    blender
    zsh
    obs-studio
    efibootmgr
    alejandra
    libnotify
    neovim
    neovide
    pkgs-unstable.anytype
    jmeter
    pkgs-unstable.aider-chat
    clang
    nodejs_22
    tor-browser-bundle-bin
    appimage-run
    foliate
    zoxide
    mtpaint
    killall
    prismlauncher
    anki
    krita
    heroku
    docker-compose
    floorp
    kitty
    discord
    git
    bat
    mullvad-vpn
    wine
    insomnia
    minikube
    kubernetes
    kubectl
    ngrok
  ];

  # LD fix
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Missing dynamic libraries here
    mesa
  ];

  # remote editor
  environment.variables.EDITOR = "neovide --no-vsync";
  environment.variables.TERMINAL = "kitty";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Gnome Tweaks
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
