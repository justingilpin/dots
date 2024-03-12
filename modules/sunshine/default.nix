{config, lib, pkgs, inputs, ...}: {
  inports = [

  ];

  # Enable Sunshine at Boot
  security.wrappers.sunshine = {
    owner = "root";
    group = "root";
    capabilities = "cap_sys_admin+p";
    source = "${pkgs.sunshine}/bin/sunshine";
  };

  systemd.user.services.sunshine =
    {
      description = "sunshine";
      wantedBy = [ "graphical-session.target" ];
      serviceConfig = {
      ExecStart = "${config.security.wrapperDir}/sunshine";
    };
  };
}
