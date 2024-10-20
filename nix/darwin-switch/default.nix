{
  pkgs,
  stdenv,
  system,
  ...
}:
let
  darwin-switch = pkgs.writeShellScriptBin "darwin-switch" ''
    if [[ ! -d $HOME/.dotfiles ]]; then
      echo 'error: path not found'; exit 1
    else
      cd "$HOME/.dotfiles" || exit 1
    fi

    /run/current-system/sw/bin/darwin-rebuild switch --flake .#macos
  '';
in
stdenv.mkDerivation rec {
  name = "darwin-switch";
  src = ./.;
  buildInputs = [ darwin-switch ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${darwin-switch}/bin/* $out/bin
  '';
}
