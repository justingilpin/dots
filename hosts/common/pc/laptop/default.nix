{ config, lib, ... }:

{
  imports = [ ../. ];

  # TLP for laptop power/heat tuning — disable power-profiles-daemon (they conflict)
  services.power-profiles-daemon.enable = lib.mkForce false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    };
  };

  # thermald as thermal backstop — needs --ignore-cpuid-check for ThinkPad dytc_lapmode
  services.thermald.enable = true;
  systemd.services.thermald.serviceConfig.ExecStart = lib.mkForce
    "/run/current-system/sw/sbin/thermald --no-daemon --adaptive --dbus-enable --ignore-cpuid-check";

  # Laptop hypridle — dims backlight and suspends after 30 min idle
  home-manager.users.justin.home.file.".config/hypr/hypridle.conf".source =
    ../../../../modules/hyprland/hypridle-laptop.conf;
}
