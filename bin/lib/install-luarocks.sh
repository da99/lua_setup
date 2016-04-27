

latest () {
  cd /progs/luarocks
  git tag | grep -P '^v\d+\.\d+\.\d+$' | tail -n 1 | cut -d'v' -f2
}

get-version () {
  $1/bin/luarocks | head -n 2 | tail -n 1  | cut -d',' -f1 | cut -d' ' -f2
}

# === {{CMD}}              # === install to $PWD/progs
# === {{CMD}}  path/to/dir # === install to $PWD/progs
install-luarocks () {
  # NOTE: I export PREFIX and LUA_DIR just in case luarocks uses
  # them in place of the "--prefix" option
  if [[ -z "$@" ]]; then
    export PREFIX="$(readlink -m "$PWD/progs")"
  else
    export PREFIX="$(readlink -m "$1")"; shift
  fi

  export SYS_CONFIG_DIR="$PREFIX"
  export LUA_DIR="$PREFIX"

  git_setup clone-or-pull https://github.com/keplerproject/luarocks.git
  cd /progs/luarocks
  git_setup checkout-latest

  local +x LATEST="$(latest)"
  if [[ -f "$PREFIX/bin/luarocks" ]]; then
    local +x CURRENT="$(get-version "$PREFIX")"
    if [[ "$CURRENT" == "$LATEST" ]]; then
      mksh_setup ORANGE "=== Already {{installed}}: $PREFIX/bin/luarocks $CURRENT" >&2
      return 0
    fi
  fi

  if [[ -f $PREFIX/bin/tarantool ]]; then
    configure-with-tarantool
  else
    if [[ -f $PREFIX/bin/laujit ]]; then
      configure-with-luajit
    else
      configure-with-lua
    fi
  fi

  make build
  make install

} # === end function

configure-with-lua () {
  ./configure               \
  --prefix="$PREFIX"         \
  --with-lua="$PREFIX"        \
  --sysconfdir="$SYS_CONFIG_DIR"         \
  --force-config
}

configure-with-luajit () {
  local +x NAME="luajit-$($PREFIX/bin/luajit -v | grep -Po '^LuaJIT \K(\d+\.\d+)(?=\.\d)')"
  ./configure               \
    --prefix="$PREFIX"         \
    --with-lua="$PREFIX"        \
    --lua-suffix="jit"           \
    --with-lua-include="$PREFIX/include/$NAME" \
    --sysconfdir="$SYS_CONFIG_DIR"         \
    --force-config
}

configure-with-tarantool () {
  ./configure                 \
    --prefix="$PREFIX"         \
    --with-lua="$PREFIX"        \
    --with-lua-include="$PREFIX/include/tarantool" \
    --lua-suffix="-tarantool" \
    --sysconfdir="$SYS_CONFIG_DIR"         \
    --force-config
} # configure-with-tarantool ()


