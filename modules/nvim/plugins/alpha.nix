{...}: {
  programs.nixvim = {
    plugins.alpha = {
      enable = true;
      theme = starify;
      iconsEnabled = true;
    };
  };
}
