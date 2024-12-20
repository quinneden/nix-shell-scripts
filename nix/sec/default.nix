{
  pkgs,
  lib,
  stdenv,
  ...
}:
let
  sec = pkgs.writeShellScriptBin "sec" ''
    KEYCHAIN="secrets.keychain"

    main() {
      if [[ -z "$1" ]]; then
        print_usage
      fi

      case "$1" in
        ls) list_secrets ;;
        get) get_secret "$2" ;;
        set) set_secret "$2" "$3" ;;
        rm) delete_secret "$2" ;;
        *) print_usage ;;
      esac
    }

    list_secrets() {
      security dump-keychain $KEYCHAIN | grep 0x00000007 | awk -F= '{print $2}' | tr -d \"
    }

    get_secret() {
      if [[ -z "$1" ]]; then
        print_usage
      fi
      security find-generic-password -a $USER -s "$1" -w $KEYCHAIN
    }

    set_secret() {
      if [[ -z "$1" ]] || [[ -z "$2" ]]; then
        print_usage
      fi
      security add-generic-password -D secret -U -a $USER -s "$1" -w "$2" $KEYCHAIN
    }

    delete_secret() {
      if [[ -z "$1" ]]; then
        print_usage
      fi
      security delete-generic-password -a $USER -s "$1" $KEYCHAIN
    }

    print_usage() {
      cat << EOF
    Usage:
      sec set <name> <value>
      sec get <name>
      sec rm <name>
      sec ls
    EOF
      exit 0
    }

    main "$@"
  '';
in
stdenv.mkDerivation rec {
  name = "sec";
  src = ./.;
  buildInputs = [ sec ];
  installPhase = ''
    mkdir -p $out/bin
    cp ${sec}/bin/* $out/bin
  '';
}
