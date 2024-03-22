{ pkgs, config, lib, unstablePkgs, poetry2nix, ... }:

let
  kaleido = pkgs.python3Packages.buildPythonPackage rec {
    pname = "kaleido";
    version = "0.2.1";  # replace with the correct version

   # format = "wheel";

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256:/ZDPZCbm/y5ycQ4KaPuptR/FIcdP7gUjWHURBXlr+1w=";  # replace with the correct hash
    };

#    propagatedBuildInputs = with pkgs.python3Packages; [
      # add the dependencies of kaleido here
#    ];

    meta = with pkgs.lib; {
      description = "Kaleido for Python";
      homepage = "https://github.com/plotly/Kaleido";
      license = licenses.mit;
    };
  };



  vectorbt = pkgs.python3Packages.buildPythonPackage rec {
    pname = "vectorbt";
    version = "0.20.0";

    src = pkgs.fetchFromGitHub {
      owner = "polakowo";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256:T68znWNqvolxoUlEF+8XkORmHcZzMRjiQpILhgP+5KY=";
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      numpy
      pandas
      kaleido
      # add other dependencies here
    ];

    meta = with pkgs.lib; {
      description = "Python library for backtesting and analyzing trading strategies at scale";
      homepage = "https://github.com/polakowo/vectorbt";
      license = licenses.mit;
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    vectorbt
  ];
}
