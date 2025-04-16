{ config, pkgs, ... }:
let
  mod = "SUPER";
  term = "kitty";
  fileManager = "thunar";
  menu = "rofi -show drun";
in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",1920x1080@60,auto,1";

      # Variables
      "$terminal" = term;
      "$fileManager" = fileManager;
      "$menu" = menu;
      "$mainMod" = mod;

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      # Decoration
      decoration = {
        rounding = 10;
        layerrule = [ "blur, top" "blur, overlay" ];
        active_opacity = 1.0;
        inactive_opacity = 0.85;
        
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

      # Animations
      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];

        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      # Layout
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Input
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        
        touchpad = {
          natural_scroll = false;
        };
      };

      gestures.workspace_swipe = false;

      device = {
        name = "epic-mouse-v1";
        sensitivity = -0.5;
      };

      # Keybinds
      bind = [
        "${mod}, G, exec, ${config.home.homeDirectory}/.config/rofi/powermenu/powermenu.sh"
        "${mod}, D, exec, ${config.home.homeDirectory}/.config/hypr/tauon.sh discord"
        "${mod}, F, exec, firefox"
        "${mod}, H, exec, helix"
        "${mod}, S, exec, rofi -show drun -show-icons"
        "${mod}, A, exec, rofi-screenshot"
        "${mod}, T, exec, ${config.home.homeDirectory}/.config/hypr/tauon.sh tauon"
        "${mod}, Q, exec, ${term}"
        "${mod}, C, killactive"
        "${mod}, M, exit"
        "${mod}, E, exec, ${fileManager}"
        "${mod}, V, togglefloating"
        "${mod}, R, exec, ${menu}"

        # Focus movement
        "${mod}, left, movefocus, l"
        "${mod}, right, movefocus, r"
        "${mod}, up, movefocus, u"
        "${mod}, down, movefocus, d"

        # Workspaces
        "${mod}, 1, workspace, 1"
        "${mod}, 2, workspace, 2"
        "${mod}, 3, workspace, 3"
        "${mod}, 4, workspace, 4"
        "${mod}, 5, workspace, 5"
        "${mod}, 6, workspace, 6"
        "${mod}, 7, workspace, 7"
        "${mod}, 8, workspace, 8"
        "${mod}, 9, workspace, 9"
        "${mod}, 0, workspace, 10"

        # Window movement
        "${mod} SHIFT, 1, movetoworkspace, 1"
        "${mod} SHIFT, 2, movetoworkspace, 2"
        "${mod} SHIFT, 3, movetoworkspace, 3"
        "${mod} SHIFT, 4, movetoworkspace, 4"
        "${mod} SHIFT, 5, movetoworkspace, 5"
        "${mod} SHIFT, 6, movetoworkspace, 6"
        "${mod} SHIFT, 7, movetoworkspace, 7"
        "${mod} SHIFT, 8, movetoworkspace, 8"
        "${mod} SHIFT, 9, movetoworkspace, 9"
        "${mod} SHIFT, 0, movetoworkspace, 10"

        # Media keys
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      bindm = [
        "${mod}, mouse:272, movewindow"
        "${mod}, mouse:273, resizewindow"
      ];

      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
        "opacity 0.80 0.85, class:^(.*)$"
      ];

      # Startup
      exec-once = [
        "${config.home.homeDirectory}/.config/hypr/start.sh"
      ];
    };
  };

  # Hypridle (Idle Management)
  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = pidof hyprlock || hyprlock
      before_sleep_cmd = loginctl lock-session
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    listener {
      timeout = 180  # 5 minutes
      on-timeout = loginctl lock-session
    }

    listener {
      timeout = 330  # 10 minutes
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }

    listener {
      timeout = 1200  # 30 minutes
      on-timeout = systemctl suspend
    }
  '';

  systemd.user.services.hypridle = {
    Unit = {
      Description = "Hyprland Idle Daemon";
      After = [ "hyprland-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hypridle}/bin/hypridle -c ${config.xdg.configHome}/hypr/hypridle.conf";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };

  # Configure hyprlock (lockscreen)
  programs.hyprlock = {
    enable = true;
    settings = {
    background = {
      monitor = "";
      blur_passes = 1;
      blur_size = 7;
      noise = 0.0117;
      path = "screenshot";
    };
    general = {
      hide_cursor = true;
    };
    "input-field" = {
      monitor = "";
      size = "200,50";
      check_color = "rgb(30, 107, 204)";
      dots_center = true;
      dots_size = 0.2;
      dots_spacing = 0.35;
      fade_on_empty = false;
      font_family = "Noto Sans Bold";
      font_color = "rgb(111, 45, 104)";
      halign = "center";
      hide_input = false;
      inner_color = "rgba(0, 0, 0, 0.2)";
      outer_color = "rgba(0, 0, 0, 0)";
      outline_thickness = 2;
      placeholder_text = ''<i><span foreground="##cdd6f4">^-^</span></i>'';
      position = "0, -100";
      rounding = -1;
      valign = "center";
    };
    image = [
      # First image (wallpaper)
      {
        monitor = "";
        halign = "center";
        path = "${config.home.homeDirectory}/wallpapers/pfp2.jpg";
        position = "0, 50";
        valign = "center";
      }
      # Second image (album art)
      {
        monitor = "";
        path = "/tmp/hyprlock_art/current_cover.jpg";
        size = "120, 120";
        position = "-800, -400";
        halign = "center";
        valign = "center";
        border_size = 2;
        border_color = "rgba(80, 80, 80, 0.8)";
        rounding = 6;
        reload_time = 1;
      }
    ];

    # Similarly fix the label section
    label = [
      # Time label
      {
        monitor = "";
        color = "rgba(242, 243, 244, 0.75)";
        font_size = 95;
        font_family = "Noto Sans Bold";
        halign = "center";
        position = "0, 300";
        text = "cmd[update:1000] echo $(date +\"%H:%M:%S\")";
        valign = "center";
      }
      # Date label
      {
        monitor = "";
        color = "rgba(242, 243, 244, 0.75)";
        font_size = 22;
        font_family = "Noto Sans Bold";
        halign = "center";
        position = "0, 200";
        text = "cmd[update:1000] echo $(date +\"%A, %B %d\")";
        valign = "center";
      }
      # Music label
      {
        monitor = "";
        position = "300, -400";
        width = 100;
        height = 120;
        color = "rgba(255, 255, 255, 0.9)";
        font_size = 16;
        font_family = "Fira Code";
        halign = "left";
        valign = "center";
        text = "cmd[update:1000] ${config.home.homeDirectory}/.config/hypr/hyprlock_music.sh | tail -n +2";
      }
    ];
  };
};
}
