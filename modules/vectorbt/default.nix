{ config, pkgs, lib, unstablePkgs, ... }:

let
  kaleido = pkgs.poetry2nix.mkPoetryApplication {
    pname = "kaleido";
    version = "0.2.1";
    pyModule = "kaleido";
    src = pkgs.fetchFromGitHub {
      owner = "plotly";
      repo = pname;
      rev = "v${version}";  # Use the tag for the version
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
