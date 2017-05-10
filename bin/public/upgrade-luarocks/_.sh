

source "$THIS_DIR/bin/public/lua-bin/_.sh"
latest () {
  cd /progs/luarocks
  git tag | grep -P '^v\d+\.\d+\.\d+$' | tail -n 1 | cut -d'v' -f2
}

get-version () {
  $1/bin/luarocks | head -n 2 | tail -n 1  | cut -d',' -f1 | cut -d' ' -f2
}

# === {{CMD}}              # === install to $PWD/progs
# === PREFIX is $PWD/progs/luarocks
upgrade-luarocks () {
  local +x ORIGIN="$PWD"

  # NOTE: I export PREFIX and LUA_DIR just in case luarocks uses
  # them in place of the "--prefix" option
  export PREFIX="$(readlink -m "$PWD/progs/luarocks")"
  export SYS_CONFIG_DIR="$PREFIX"

  cd "$THIS_DIR"
  mkdir -p "tmp"; cd tmp

  if [[ -d luarocks ]]; then
    cd luarocks
    git checkout master
    git pull
  else
    git clone https://github.com/keplerproject/luarocks.git
    cd luarocks
  fi

  my_git checkout-latest

  local +x LATEST="$(latest)"
  if [[ -f "$PREFIX/bin/luarocks" ]]; then
    local +x CURRENT="$(get-version "$PREFIX")"
    if [[ "$CURRENT" == "$LATEST" ]]; then
      sh_color ORANGE "=== Already {{installed}}: BOLD{{$CURRENT}} in BOLD{{$PREFIX/bin/luarocks}}" >&2
      return 0
    fi
  fi

  local +x BIN="$ORIGIN/$(cd "$ORIGIN" && lua-bin)"
  local +x LUA_DIR="$(dirname "$(dirname "$BIN")")"

  case "$BIN" in
    */luajit) # luajit goes first since it symlinks to lua bin.
        local +x NAME="$($BIN -v | grep -Po '^LuaJIT \K(\d+\.\d+)(?=\.\d)')"
        ./configure               \
          --prefix="$PREFIX"         \
          --with-lua="$LUA_DIR"        \
          --lua-suffix="jit"           \
          --with-lua-include="$(find "$(realpath -m "$LUA_DIR/..")" -type d -path "*/include/luajit-*")" \
          --sysconfdir="$SYS_CONFIG_DIR"         \
          --force-config
      ;;

    */lua)
        ./configure               \
        --prefix="$PREFIX"         \
        --with-lua="$LUA_DIR"        \
        --sysconfdir="$SYS_CONFIG_DIR"         \
        --force-config
      ;;

    */tarantool)
        ./configure                        \
          --prefix="$PREFIX"               \
          --with-lua="$LUA_DIR"             \
          --lua-suffix="-tarantool"        \
          --sysconfdir="$SYS_CONFIG_DIR"   \
          --with-lua-include="$(find "$LUA_DIR" -type d -path "*/include/tarantool")" \
          --force-config
      ;;

    *)
      sh_color RED "!!! Lua not found for {{luarocks}} installation."
      exit 1
      ;;
  esac

  make build
  make install

  sh_color BOLD "=== Installed: {{$(get-version "$PREFIX")}}"
} # === end function



