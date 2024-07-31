{ self, config, lib, pkgs, ...}: {

  environment.etc."nextcloud-admin-pass".text = "n^V8KWNETiE6pQhEz7T3";
  services.nextcloud = {
    enable = true;
    hostName = "192.168.88.62";
    config.adminpassFile = "/etc/nextcloud-admin-pass";
  };

}
