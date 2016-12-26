
source "$THIS_DIR/bin/public/lua-bin/_.sh"

# === {{CMD}} --list           # List rocks installed.
# === {{CMD}} --install FILE   # Install luarocks in file (generated from: {{BIN}} rocks).
# === {{CMD}} --extra   FILE   # List rocks not found in file.
# === {{CMD}} --need    FILE   # List rocks that need to be installed.
# === NOTE: Assumes luarocks is installed in progs/luarocks.
bundle () {
  local +x ACTION="$1"; shift
  local +x LUAROCKS="progs/luarocks/bin/luarocks"

  case "$ACTION" in
    --list)
      "$(lua-bin)" -e '
        dofile("progs/luarocks/lib/luarocks/rocks/manifest");
        for name, about in pairs(dependencies) do
          for ver, other in pairs(about) do
            print(name .. " " .. ver );
          end
        end' | sort
      ;;

    --install)
      local +x BUNDLE="$1"; shift
      local +x EXTRA="$(bundle --extra "$BUNDLE")"

      if [[ ! -z "$EXTRA" ]]; then
        echo "!!! Extra rocks found:" >&2
        echo "$EXTRA"                 >&2
        exit 1
      fi

      local +x IFS=$'\n'
      for LINE in $(bundle --needed "$BUNDLE"); do
        local +x NAME="$(echo $LINE | cut -d' ' -f1)"
        local +x VER="$(echo $LINE | cut -d' ' -f2)"
        if ( "$LUAROCKS" show "$NAME" | head -n2 | grep " $VER " ) >/dev/null; then
          echo "=== Already installed: $NAME $VER"
          continue
        else
          echo "=== Installing: $LINE"
          exit 1
          "$LUAROCKS" install $NAME  $VER
        fi
      done
      ;;

    --extra)
      bash -c "comm -23  <($0 bundle) "$1""
      ;;

    --need)
      bash -c "comm -23 "$1" <($0 bundle --list) "
      ;;

    *)
      echo "!!! Unknown args: $ACTION $@" >&2
      exit 1
      ;;
  esac

} # === end function


