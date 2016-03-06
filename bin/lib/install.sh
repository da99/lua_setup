
# === {{CMD}}
# === {{CMD}}  $PWD/my-dir
install () {
  local PREFIX
  if [[ -z "$@" ]]; then
    PREFIX="$PWD/lua"
  else
    PREFIX="$@"
  fi

  git_setup clone_or_pull "http://luajit.org/git/luajit-2.0.git"
  cd /progs/luajit-2.0
  git_setup checkout-latest

  mkdir -p "$PREFIX"
  make         PREFIX="$PREFIX"
  make install PREFIX="$PREFIX"

  $0 install-luarocks "$PREFIX"
} # === end function
