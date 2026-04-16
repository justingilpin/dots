{ config, lib, ... }:

{
  imports = [ ../. ];

  # TLP for laptop power/heat tuning — disable power-profiles-daemon (they conflict)
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  # thermald as thermal backstop — prevents CPU from running dangerously hot
  services.thermald.enable = true;

  # Laptop hypridle — dims backlight and suspends after 30 min idle
  home-manager.users.justin.home.file.".config/hypr/hypridle.conf".source =
    ../../../../modules/hyprland/hypridle-laptop.conf;
}
