{ ... }: {
  programs.alacritty = {
		settings = {
      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };
        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };
        indexed_colors = [
          {
            index = 16;
            color = "#4c566a"; # 0xff9e64
          }
          {
            index = 17;
            color = "#2e3440"; # 0xdb4b4b
          }
        ];
      };
    };
  };
}
