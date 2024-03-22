{ pkgs, config, lib, unstablePkgs, ... }:

let
  python = pkgs.python39;
  pythonPackages = python.pkgs;

  requests = pythonPackages.buildPythonPackage rec {
    pname = "requests";
    version = "2.26.0";

    src = pythonPackages.fetchPypi {
      inherit pname version;
      sha256 = "uKpY+M95P/2HgtPYyxnmbvNverpDU+7IWedGeLAbB6c=";
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
