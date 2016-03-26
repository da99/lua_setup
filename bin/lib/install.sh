

# === {{CMD}}              # defaults to $PWD/progs
# === {{CMD}}  $PWD/my-dir
# === Installs: luajit, luarocks, openresty
install () {
  # NOTE: I export PREFIX and LUA_DIR just in case
  # luajit uses them in place of the "--prefix" option
  export PREFIX
  export LUA_DIR
  if [[ -z "$@" ]]; then
    PREFIX="$PWD/progs"
    mkdir -p "$PREFIX"
  else
    PREFIX="$@"
  fi
  LUA_DIR="$PREFIX"

  bash_setup BOLD "=== Installing to: {{$PREFIX}}"
  git_setup clone-or-pull "http://luajit.org/git/luajit-2.0.git"
  cd /progs/luajit-2.0
  git_setup checkout-latest

  bash_setup BOLD "=== Installing {{LuaJIT}}"
  mkdir -p "$PREFIX"
  make         PREFIX="$PREFIX"
  make install PREFIX="$PREFIX"

  $0 install-luarocks  "$PREFIX"
  $PREFIX/bin/luarocks || {
    stat=$?;
    bash_setup RED "=== Tip: remove the luajit dir and start over";
    exit $stat;
  }
  $0 install-openresty "$PREFIX"

} # === end function


