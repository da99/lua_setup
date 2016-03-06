
# === {{CMD}}
# === {{CMD}}  $PWD/my-dir
install () {
  # NOTE: I export PREFIX and LUA_DIR just in case
  # luajit uses them in place of the "--prefix" option
  export PREFIX
  export LUA_DIR
  if [[ -z "$@" ]]; then
    PREFIX="$PWD/luajit"
  else
    PREFIX="$@"
  fi
  LUA_DIR="$PREFIX"

  git_setup clone_or_pull "http://luajit.org/git/luajit-2.0.git"
  cd /progs/luajit-2.0
  git_setup checkout-latest

  mkdir -p "$PREFIX"
  make         PREFIX="$PREFIX"
  make install PREFIX="$PREFIX"

  $0 install-luarocks "$PREFIX"
} # === end function
