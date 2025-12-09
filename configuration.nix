{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Basic system
  networking.hostName = "nixos-laptop";
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  system.stateVersion = "25.11"; # set to your NixOS version

  # 用户帐户
  users.users.wen = {
    isNormalUser = true;
    description = "wen";
    home = "/home/wen";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    initialPassword = "3014";
  };

  # Sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # Networking
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = true; # 需要时在本机关闭以提高安全
  };

  # Desktop: Hyprland with SDDM on physical machine
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "hyprland";

  # GPU / OpenGL (driver selection depends on hardware)
  hardware.opengl = { enable = true; extraPackages = with pkgs; [ ]; };

  # Allow unfree packages if you want Chrome/WPS
  nixpkgs.config = { allowUnfree = true; };
  hardware.enableRedistributableFirmware = true;

  # Sound (PipeWire)
  services.pipewire.enable = true;
  hardware.pulseaudio = { enable = false; };

  # Power for laptops
  services.tlp.enable = true;

  # Firewall
  networking.firewall.enable = true;

  # Bootloader (do not change this lightly on a running system)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # System packages (desktop-focused). After WSL validation you can tune this list.
  environment.systemPackages = with pkgs; [
    # Core
    vim git wget curl htop neofetch

    # Terminal + launcher
    alacritty rofi

    # Wayland desktop
    hyprland waybar mako swww

    # Clipboard / screenshot
    wl-clipboard grim slurp

    # Desktop portal (for Flatpak and Wayland features)
    xdg-desktop-portal xdg-desktop-portal-wlr

    # Multimedia
    pipewire pipewire-alsa pipewire-pulse wireplumber mpv ffmpeg vlc

    # Input
    fcitx5 fcitx5-rime fcitx5-chinese-addons fcitx5-configtool

    # Fonts
    noto-fonts-cjk-sans noto-fonts-cjk-serif sarasa-gothic

    # Browsers & packaging
    firefox google-chrome flatpak

    # Utilities
    pavucontrol imagemagick obs-studio btop
  ];

  # Minimal root filesystem placeholder for WSL testing; on a real machine keep the generated hardware-configuration.nix
  fileSystems = {
    "/" = {
      device = "/dev/root";
      fsType = "auto";
    };
  };

  # Input method environment variables
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx5";
    QT_IM_MODULE = "fcitx5";
    XMODIFIERS = "@im=fcitx5";
    LANG = "zh_CN.UTF-8";
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };

  # Fonts (also available in environment.systemPackages)
  fonts.fonts = with pkgs; [ noto-fonts-cjk-sans noto-fonts-cjk-serif sarasa-gothic ];

  # Flatpak service
  services.flatpak.enable = true;

  # Disable automatic system upgrades by default
  system.autoUpgrade.enable = false;

  # Notes for deploy: do not hardcode substituters/trusted-keys here if you plan to pass them via the deploy script.
}
