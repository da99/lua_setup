
# === {{CMD}} $PWD/my-dir
# === PREFIX is required, unlike "lua_setup install"
# === For now: The PREFIX should be the same as the luajit install.
install-luarocks () {
  # NOTE: I export PREFIX and LUA_DIR just in case luarocks uses
  # them in place of the "--prefix" option
  export PREFIX="$@"
  export LUA_DIR="$PREFIX"

  git_setup clone-or-pull https://github.com/keplerproject/luarocks.git
  cd /progs/luarocks
  git_setup checkout-latest

  local NAME="luajit-$($PREFIX/bin/luajit -v | grep -Po '^LuaJIT \K(\d+\.\d+)(?=\.\d)')"

  ./configure               \
  --prefix="$PREFIX"         \
  --with-lua="$PREFIX"        \
  --lua-suffix="jit"           \
  --with-lua-include="$PREFIX/include/$NAME" \
  --sysconfdir="$PREFIX"         \
  --force-config

  make build
  make install
} # === end function
