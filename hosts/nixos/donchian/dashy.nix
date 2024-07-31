{ config, pkgs, lib, ... }: {

  virtualisation.oci-containers.containers = {


    dashy = {
      image = "lissy93/dashy";
      ports = [ "192.168.88.62:4000" ];
      volumes = [ "/home/user/.config/dashy/conf.yml:/app/public/conf.yml" ];
    };
    };

  systemd.services.docker-dashy.serviceConfig.TimeoutStopSec = lib.mkForce 15;
}
