{ ... }: {
	imports = [
	  ./nord.nix
	];
  programs.alacritty = {
    enable = true;
    settings = {
#      window = {
#        opacity = 1;
#        dynamic_title = true;
#        dynamic_padding = true;
#        decorations = "full";
#        dimensions = {
#          lines = 0;
#          columns = 0;
#        };
#        padding = {
#          x = 5;
#          y = 5;
#        };
#      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      mouse = { hide_when_typing = true; };

      font = let fontname = "JetBrainsMono Nerd Font";
      in {
        normal = {
          family = fontname;
          style = "Bold";
        };
        bold = {
          family = fontname;
          style = "ExtraBold";
        };
        italic = {
          family = fontname;
          style = "ExtraLight";
        };
#        size = 17;
      };
      cursor.style = "Block";

      # nord theme
#      colors = {
#        primary = {
#          background = "#2e3440";
#          foreground = "#d8dee9";
#        };
#        normal = {
#          black = "#3b4252";
#          red = "#bf616a";
#          green = "#a3be8c";
#          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
#          white = "#e5e9f0";
#        };
#        bright = {
#          black = "#4c566a";
#          red = "#bf616a";
#          green = "#a3be8c";
#          yellow = "#ebcb8b";
#          blue = "#81a1c1";
#          magenta = "#b48ead";
#          cyan = "#8fbcbb";
#          white = "#eceff4";
#        };
#        indexed_colors = [
#          {
#            index = 16;
#            color = "#4c566a"; # 0xff9e64
#          }
#          {
#            index = 17;
#            color = "#2e3440"; # 0xdb4b4b
#          }
#        ];
#      };
    };
  };
}
