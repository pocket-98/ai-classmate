with import <nixpkgs> {};

pkgs.mkShell {
  name = "python-env";

  packages = with pkgs; [
    bash
    zlib
    zip
    unzip
    pandoc
    (python3.withPackages (ps: with ps; [
      ps.setuptools
      ps.virtualenv
    ]))
  ];

  buildInputs = with pkgs; [
    pkgs.stdenv.cc.cc.lib
    pkgs.zlib
    pkgs.openssl
    pkgs.libjpeg
  ];

  env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.stdenv.cc.cc
    pkgs.zlib
    pkgs.openssl
    pkgs.libjpeg
  ];


  # This hook automatically creates and activates a virtual environment
  inputsFrom = [ ];
  shellHook = ''
    export TMPDIR=/tmp
    export TMP=/tmp
    export PATH="${pkgs.stdenv.cc}/bin:$PATH"
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH"

    # 1. Define the virtual environment directory
    VENV=.pyenv

    # 2. Create the venv if it doesn't exist
    if [ ! -d "$VENV" ]; then
      echo "Creating virtual environment..."
      python3 -m venv "$VENV"
    fi

    # 3. Activate the virtual environment
    source "$VENV/bin/activate"

    # 4. Run pip install automatically
    echo "Installing dependencies for pptx2md ..."
    pip install --no-binary :all: pptx2md || pip install pptx2md
  '';
}

