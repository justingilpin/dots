{ pkgs, config, lib, unstablePkgs, ... }:

let
  python = pkgs.python39;
  pythonPackages = python.pkgs;

  requests = pythonPackages.buildPythonPackage rec {
    pname = "requests";
    version = "2.26.0";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "0d6f53a15db4120f2b08c94f11e7dc8d2e05c6e5c38e6c7b1a5b7996355f096c";
    };

    propagatedBuildInputs = with pythonPackages; [
      certifi
      chardet
      idna
      urllib3
    ];
  };
in
{
  environment.systemPackages = with pkgs; [
    requests
  ];
}
