
# === {{CMD}} $PWD/my-dir
# === PREFIX is required, unlike "lua_setup install"
# === For now: The PREFIX should be the same as the luajit install.
install-luarocks () {
  local PREFIX="$1"
  git_setup clone_or_pull https://github.com/keplerproject/luarocks.git
  cd /progs/luarocks
  git_setup checkout-latest

  export LUA_DIR="$PREFIX"
  local NAME="luajit-$($PREFIX/bin/luajit -v | grep -Po '^LuaJIT \K(\d+\.\d+)(?=\.\d)')"
  set -x
  ./configure               \
  --prefix="$PREFIX"         \
  --with-lua="$PREFIX"        \
  --lua-suffix="jit"           \
  --with-lua-include="$PREFIX/include/$NAME" \
  --sysconfdir="$PREFIX"         \
  --force-config

  make
  make install
} # === end function
