{ pkgs, lib, ... }:

let
  NIXOS_VERSION = "24.11";
  HOME_MANAGER_PACKAGE = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${NIXOS_VERSION}.tar.gz";

  MAIN_USER = "USERNAME";

  WALLPAPER_IMAGE = ./files/wallpaper.png;
  WAYBAR_CONFIG_DIRECTORY = ./files/waybar;
  KITTY_CONFIG = ./files/kitty/kitty.conf;
in
{
  services.xserver = {
    enable = true;

    displayManager = {
      gdm = {
        enable = true;
        wayland = true;
      };
    };
  };

  programs = {
    hyprland = {
      enable = true;
      xwayland.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # file manager
    nautilus
    # console
    kitty
    # app launcher
    walker
    # wallapaper
    hyprpaper
    # keyring
    seahorse
    # theming
    nwg-look
    # screenshot
    hyprshot
    # clipboard
    wl-clip-persist

    # utils
    brightnessctl
    playerctl
    networkmanagerapplet

    # others
    gnome-calculator
    gnome-text-editor
  ];

  # polkit
  security.polkit.enable = true;
  # keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.gdm-password.enableGnomeKeyring = true;
  # enables trash
  services.gvfs.enable = true;
  # waybar icons
  fonts.packages = with pkgs; [                                                                          
    font-awesome
  ];
  # power-profiles-daemon
  services.power-profiles-daemon.enable = true;

  home-manager = {
    users.${MAIN_USER} = {
      home = {
        stateVersion = NIXOS_VERSION;

        file = lib.mkMerge [
          # copy resources from `./files`
          {
            "/Pictures/Wallpapers/nixos-wallpaper.png" = {
              source = WALLPAPER_IMAGE;
            };
          }
          {
            ".config/waybar" = {
              source = WAYBAR_CONFIG_DIRECTORY;
              recursive = true;
            };
          }
          {
            ".config/kitty/kitty.conf" = {
              source = KITTY_CONFIG;
            };
          }
          # ensure scripts are executable
          {
            ".config/waybar/waybar.sh" = {
              source = WAYBAR_CONFIG_DIRECTORY + "/waybar.sh";
              executable = true;
            };
          }
          {
            ".config/waybar/modules/mediaplayer.py" = {
              source = WAYBAR_CONFIG_DIRECTORY + "/modules/mediaplayer.py";
              executable = true;
            };
          }
        ];
      };

      programs = {
        waybar = {
          enable = true;
        };

        vscode = {
          enable = true;
          package = pkgs.vscodium;
        };

        chromium = {
          enable = true;
          package = pkgs.chromium;
        };
      };

      services = {
        hyprpaper = {
          enable = true;
          settings = {
            preload = [
              "~/Pictures/Wallpapers/nixos-wallpaper.png"
            ];
            wallpaper = [
              ", ~/Pictures/Wallpapers/nixos-wallpaper.png"
            ];
          };
        };
      };

      wayland.windowManager.hyprland = {
        enable = true;
        systemd.enable = false;
        systemd.variables = ["--all"];

        # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
        settings = {
          "$terminal" = "kitty";
          "$fileManager" = "nautilus";
          "$menu" = "walker";
          "$mainMod" = "SUPER";
          "$code" = "codium";
          "$browser" = "chromium --incognito";
          "$editor" = "gnome-text-editor";

          # pass session variables to hyprland
          # instead of environment.sessionVariables
          env = [
            "NIXOS_OZONE_WL, 1"
            "GTK_THEME, Dark-Gruvbox" # required for Nautilus to apply current theme
            "XDG_SESSION_DESKTOP, Hyprland"
            "XDG_CURRENT_DESKTOP, Hyprland"
            "XDG_DESKTOP_DIR, $HOME/Desktop"
            "XDG_DOWNLOAD_DIR, $HOME/Downloads"
            "XDG_TEMPLATES_DIR, $HOME/Templates"
            "XDG_PUBLICSHARE_DIR, $HOME/Public"
            "XDG_DOCUMENTS_DIR, $HOME/Documents"
            "XDG_MUSIC_DIR, $HOME/Music"
            "XDG_PICTURES_DIR, $HOME/Pictures"
            "XDG_VIDEOS_DIR, $HOME/Videos"
            "HYPRSHOT_DIR, $HOME/Pictures/Screenshots"
          ];

          exec-once = [
            "sh ~/.config/waybar/waybar.sh"
            "hyprpaper"
            "wl-clip-persist"
            "power-profiles-daemon"
            "nm-applet --no-agent"
          ];

          # monitors
          monitor = [
            # left
            # "DP-4,     1920x1080@60,  0x0,    1" 
            # center
            # "HDMI-A-1, 1920x1080@120, 1920x0, 1"
            # right
            # "eDP-1,    1920x1080@60,  3840x0, 1"
          ];
    
          general = {
            "$mainMod" = "SUPER";
            layout = "dwindle";
            gaps_in = 1;
            gaps_out = 1;
            border_size = 1;
            resize_on_border = true;
          };

          decoration = {
            rounding = 5;

            active_opacity = 1.0;
            inactive_opacity = 0.99;

            shadow = {
              enabled = true;
              range = 4;
              render_power = 3;
              color = "rgba(1a1a1aee)";
            };

            blur = {
              enabled = true;
              size = 3;
              passes = 1;
              vibrancy = 0.1696;
            };
          };

          dwindle = {
            pseudotile = true; # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = true; # You probably want this
          };

          misc = {
            force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo = true; # If true disables the random hyprland logo / anime girl background. :(
          };

          input = {
            kb_layout = "us";
            kb_variant = "alt-intl";

            follow_mouse = 1;

            sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

            touchpad = {
              natural_scroll = false;
            };

            numlock_by_default = true;
          };

          gestures = {
            workspace_swipe = true;
          };

          bind = [
            "$mainMod, T, exec, $terminal"
            "$mainMod, E, exec, $fileManager"

            "$mainMod, 1, exec, $menu"
            "$mainMod, 2, exec, $code"
            "$mainMod, 3, exec, $browser"
            "$mainMod, 4, exec, $editor"

            "$mainMod, Q, killactive,"
            "$mainMod, M, exit,"
            
            "$mainMod, left, movefocus, l"
            "$mainMod, right, movefocus, r"
            "$mainMod, up, movefocus, u"
            "$mainMod, down, movefocus, d"

            "$mainMod SHIFT, V, togglefloating"
            "$mainMod SHIFT, P, pseudo, " # dwindle
            # "$mainMod, J, togglesplit, " # dwindle

            "$mainMod, mouse_down, movetoworkspace, e+1"
            "$mainMod, mouse_up, movetoworkspace, e-1"

            ", PRINT, exec, hyprshot -m region"
          ];
          bindm = [
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
          ];
          bindl = [
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPause, exec, playerctl play-pause"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioPrev, exec, playerctl previous"
          ];
          bindel = [
            ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
            ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
            ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ",XF86MonBrightnessUp, exec, brightnessctl s 10%+"
            ",XF86MonBrightnessDown, exec, brightnessctl s 10%-"
          ];

          windowrule = [
            "suppressevent maximize, class:.*"
            "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
          ];
        };
      };
    };
  };
}
