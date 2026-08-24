{ config, pkgs, inputs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ai-classmate"; # Define your hostname.
  networking.networkmanager.enable = true;
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users."pocket" = {
    isNormalUser = true;
    description = "pocket";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  #home-manager.useGlobalPkgs = true;
  #home-manager.useUserPackages = true;
  #home-manager.users."pocket" = import ./home.nix;


  environment.systemPackages = with pkgs; [
    vim
    gnumake
    htop
    tmux
    git
    python3
    nodejs_26
    home-manager
    gnupg
    pinentry-tty
    inputs.llm-agents.packages.x86_64-linux.hermes-agent
  ];

  #sops.defaultSopsFile = "/etc/nixos/secrets.yaml";
  #sops.gnupg.home = "/home/pocket/.gnupg";

  # programs.mtr.enable = true;

  programs.firefox.enable = true;

  programs.bash = {
    enable = true;
    completion.enable = true;
  };

  # gpg
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    enableSSHSupport = true;
  };

  services.openssh.enable = true;

  programs.tmux = {
    enable = true;
    clock24 = true;
    extraConfig = ''
      set-option -g repeat-time 100
      set-option -g mouse on
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };

  # hermes
  #programs.hermes-agent = {
  #  enable = true;
  #  settings.model.default = "openai/gpt-4o";
  #  environmentFiles = [ "/home/pocket/secrets/hermes-env" ];
  #  addToSystemPackages = true;
  #};

  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.allowedUDPPorts = [ ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
