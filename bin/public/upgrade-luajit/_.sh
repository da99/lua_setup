
# === {{CMD}}
# === {{CMD}}  install-dir/
upgrade-luajit () {
  local SRC="$THIS_DIR/tmp/luajit"

  export PREFIX

  if [[ -z "$@" ]]; then
    PREFIX="$(realpath -m progs/)"
  else
    PREFIX="$1"
    shift
  fi

  sh_color ORANGE "=== Using prefix: {{$PREFIX}}"
  mkdir -p "$PREFIX/bin"

  if [[ ! -d "$SRC" ]]; then
    git clone http://luajit.org/git/luajit-2.0.git "$SRC"
    cd "$SRC"
  else
    cd "$SRC"
    git pull
  fi

  make clean
  make         PREFIX="$PREFIX"
  make install PREFIX="$PREFIX"

  $PREFIX/bin/luajit -v
} # === end function

