{ config, pkgs, lib, unstablePkgs, poetry2nix, ... }:

let
#  poetry2nix = import (pkgs.fetchFromGitHub {
#    owner = "nix-community";
#    repo = "poetry2nix";
#    rev = "1.21.0";  # Use the latest release
#    sha256 = "sha256:11r27qy4pnqsqhbvxd3vn6sm1s8zl190d2q1v9k2w0r296bdrw4c";
#  });


  kaleido = pkgs.python3Packages.buildPythonPackage rec {
    pname = "kaleido";
    version = "0.2.1";
    # pyModule = "kaleido";
    src = pkgs.fetchFromGitHub {
      owner = "plotly";
      repo = "kaleido";
      rev = "v${version}"; 
      sha256 = "sha256:/ZDPZCbm/y5ycQ4KaPuptR/FIcdP7gUjWHURBXlr+1w=";
    };
  #  format = "pyproject";
    meta = with pkgs.lib; {
      description = "Static image export for web-based visualization libraries";
      homepage = "https://github.com/plotly/kaleido";
      license = licenses.mit;
    };
#      buildPhase = ''
    # replace this with the actual build commands for the package
#    poetry build
#  '';

#  installPhase = ''
    # replace this with the actual install commands for the package
#    poetry install --no-root
#  '';
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
