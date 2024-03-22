{ config, pkgs, lib, unstablePkgs, ... }:

let
  poetry2nix = import (pkgs.fetchFromGitHub {
    owner = "nix-community";
    repo = "poetry2nix";
    rev = "1.21.0";  # Use the latest release
    sha256 = "sha256:11r27qy4pnqsqhbvxd3vn6sm1s8zl190d2q1v9k2w0r296bdrw4c";  # Replace with the correct SHA-256 hash
  }) {};

  kaleido = pkgs.poetry2nix.mkPoetryApplication {
    pname = "kaleido";
    version = "0.2.1";
    pyModule = "kaleido";
    src = pkgs.fetchFromGitHub {
      owner = "plotly";
      repo = "kaleido";
      rev = "version"; 
      sha256 = "sha256:1k1hlkdlh4h00p0xjqn9ypvnhycv1pjqn2m9f3qg2s5pribh36wl";
    };
    format = "pyproject";
    meta = with pkgs.lib; {
      description = "Static image export for web-based visualization libraries";
      homepage = "https://github.com/plotly/kaleido";
      license = licenses.mit;
    };
  };  


  vectorbt = pkgs.python3Packages.buildPythonPackage rec {
    pname = "vectorbt";
    version = "0.20.0";

    src = pkgs.fetchFromGitHub {
      owner = "polakowo";
      repo = pname;
      rev = "v${version}"; # use the tag for the version
      sha256 = "sha256-T68znWNqvolxoUlEF+8XkORmHcZzMRjiQpILhgP+5KY=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [ numpy pandas kaleido ];

    meta = with pkgs.lib; {
      description = "Python library for backtesting and analyzing trading strategies at scale";
      homepage = "https://github.com/polakowo/vectorbt";
      license = licenses.mit;
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    python3
    python3Packages.numpy
    python3Packages.pandas
    kaleido
    vectorbt
  ];
}
