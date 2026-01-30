{ config, lib, pkgs, ... }:

let
  mkScript = {
    name ? "script",
    deps ? [],
    script ? "",
  }:
    lib.getExe (pkgs.writeShellApplication {
      inherit name;
      text = script;
      runtimeInputs = deps;
    });
in {
  programs.waybar = {
    enable = true;
    settings = {
      primary = {
        height = 26;
        margin = "5";
        spacing = 10;
        output = "DSI-1";
        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = [
          "tray"
          "idle_inhibitor"
          "backlight"
          "wireplumber"
          "battery"
          "disk"
          "memory"
          "cpu"
          "temperature"
          "clock"
        ];

        "hyprland/workspaces" = {
          show-special = true;
          persistent-workspaces = {"*" = [1 2 3 4 5 6 7 8 9 10];};
          format = "{icon}";
          format-icons = {
            active = "";
            empty = "";
            default = "";
            urgent = "";
            special = "󰠱";
          };
        };

        "hyprland/window" = {
          icon = true;
          icon-size = 22;
          rewrite = {
            "(.*) — Mozilla Firefox" = "$1 - 🦊";
            "(.*) - Visual Studio Code" = "$1 - 󰨞 ";
            "(.*) - Discord" = "$1 - 󰙯 ";
            "^$" = "---";
          };
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰛊 ";
            deactivated = "󰾫 ";
          };
        };

        backlight = {
          interval = 2;
          format = "󰖨 {percent}%";
          on-scroll-up = "brightnessctl set +4";
          on-scroll-down = "brightnessctl set 4-";
        };

        wireplumber = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 ";
          format-icons = ["" "" "" "" ""];
        };

        battery = {
          interval = 10;
          format = "{icon}{capacity}%";
          format-icons = ["󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
          tooltip-format = "{timeTo}";
        };

        disk = {
          interval = 30;
          format = "󰋊 {percentage_used}%";
          tooltip-format = "{used} used out of {total} on \"{path}\" ({percentage_used}%)";
        };

        memory = {
          interval = 10;
          format = " {used}";
          tooltip-format = "{used}GiB used of {total}GiB ({percentage}%)";
        };

        cpu = {
          interval = 10;
          format = " {usage}%";
        };

        temperature = {
          interval = 10;
        };

        clock = {
          interval = 1;
          format = "{:%H:%M:%S}";
        };
      };
    };

    style = ''
      * {
        font-family: "JetBrains Mono NerdFont";
        font-size: 0.8rem;
        padding: 0;
        margin: 0 0.1em;
      }

      window#waybar {
        background-color: rgba(0, 0, 0, 0);
        border-radius: 0.5rem;
      }

      .modules-left, .modules-center {
        background: linear-gradient(50deg, rgb(150, 222, 209), rgb(5, 166, 252));
        color: #ffffff;
        border-radius: 0.5rem;
        padding: 0 1px;
        margin: 0 1px;
      }

      .modules-right {
        background-color: rgba(0,0,0,0.5);
        border-radius: 0.5rem;
        padding: 0 5px;
        margin: 0 1px;
        color: #ffffff;
        border-left: 2px solid rgb(150, 222, 209);
        border-right: 2px solid rgb(5, 166, 252);
      }

      label.module {
        margin-left: -1px;
      }

      #workspaces {
        background-color: rgba(0,0,0,0.5);
        border-radius: 0.5rem;
        padding: 0 1px;
        margin: 0 1px;
      }

      #workspaces button {
        font-size: 0.6rem;
        padding: 0 0.2rem;
        margin: 0 1px;
        color: #ffffff;
      }

      #window {
        background-color: rgba(0,0,0,0.5);
        border-radius: 0.5rem;
        padding: 0 3px;
        margin: 0 1px;
      }

      #clock {
        font-weight: bolder;
        border-radius: 0.5rem;
        padding: 0 2px;
        margin: 0 1px;
      }

      #custom-waybar-scrolling-mpris {
        color: #ffa07a;
        padding: 0 5px;
        min-width: 200px;
      }
 
      #battery { color: #90ee90; }
      #memory { color: #ffb6c1; }
      #disk { color: #87cefa; }
      #cpu { color: #fafad2; }
      #temperature { color: #778899; }
    '';
  };
}
