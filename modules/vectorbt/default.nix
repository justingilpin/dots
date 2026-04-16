{ config, pkgs, lib, ... }:

let
  # NautilusTrader is not yet in nixpkgs — build from PyPI source.
  # It requires Cython at build time and links against system libs via nix-ld.
  nautilusTrader = pkgs.python3Packages.buildPythonPackage rec {
    pname = "nautilus_trader";
    version = "1.208.0";
    format = "wheel";

    src = pkgs.fetchPypi {
      inherit pname version format;
      python = "cp312";
      abi = "cp312";
      platform = "manylinux_2_28_x86_64";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # update with nix-prefetch-url
    };

    propagatedBuildInputs = with pkgs.python3Packages; [
      numpy
      pandas
      msgspec
      pyarrow
      uvloop
    ];

    meta = with pkgs.lib; {
      description = "High-performance algorithmic trading platform and event-driven backtester";
      homepage = "https://nautilustrader.io";
      license = licenses.lgpl3;
    };
  };

  # kaleido provides static image export for vectorbt's plotly charts
  kaleido = pkgs.python3Packages.buildPythonPackage rec {
    pname = "kaleido";
    version = "0.2.1";
    src = pkgs.fetchFromGitHub {
      owner = "plotly";
      repo = "kaleido";
      rev = "v${version}";
      sha256 = "sha256:/ZDPZCbm/y5ycQ4KaPuptR/FIcdP7gUjWHURBXlr+1w=";
    };
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
      rev = "v${version}";
      sha256 = "sha256-T68znWNqvolxoUlEF+8XkORmHcZzMRjiQpILhgP+5KY=";
    };
    propagatedBuildInputs = with pkgs.python3Packages; [ numpy pandas kaleido ];
    meta = with pkgs.lib; {
      description = "Python library for backtesting and analyzing trading strategies at scale";
      homepage = "https://github.com/polakowo/vectorbt";
      license = licenses.mit;
    };
  };

  # Python env bundling all trading/backtesting deps together
  tradingPython = pkgs.python3.withPackages (ps: with ps; [
    numpy
    pandas
    kaleido
    vectorbt
    # Dukascopy free-tier data via duka (pip install duka)
    # Not in nixpkgs — install in project venv: pip install duka
  ]);

in
{
  environment.systemPackages = [
    tradingPython
    # nautilusTrader   # uncomment after fixing the wheel sha256 below
  ];
}
