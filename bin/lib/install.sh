
source "$THIS_DIR/bin/lib/install-luarocks.sh"
source "$THIS_DIR/bin/lib/install-openresty.sh"

# === {{CMD}}              # defaults to $PWD/progs
# === Installs: luajit, luarocks, openresty
install () {
  # NOTE: I export PREFIX and LUA_DIR just in case
  # luajit uses them in place of the "--prefix" option
  export PREFIX="$(readlink -m "$PWD/progs")"
  mkdir -p "$PREFIX"
  export LUA_DIR="$PREFIX"

  bash_setup BOLD "=== Installing to: {{$PREFIX}}"
  git_setup clone-or-pull "http://luajit.org/git/luajit-2.0.git"
  cd /progs/luajit-2.0
  git_setup checkout-latest

  bash_setup BOLD "=== Installing {{LuaJIT}}"
  mkdir -p "$PREFIX"
  make         PREFIX="$PREFIX"
  make install PREFIX="$PREFIX"

  cd "$PREFIX"
  install-luarocks
  $PREFIX/bin/luarocks || {
    stat=$?;
    bash_setup RED "=== Tip: remove the luajit dir and start over";
    exit $stat;
  }

  install-openresty

} # === end function


