
# === {{CMD}}
# === PREFIX is set to $PWD/progs/luajit
upgrade-luajit () {

  local +x ORIGIN="$PWD"
  local +x SRC="luajit"

  export PREFIX

  PREFIX="$ORIGIN/progs/luajit"

  sh_color ORANGE "=== Using prefix: {{$PREFIX}}"
  mkdir -p "$PREFIX"

  mkdir -p "$THIS_DIR/tmp"
  cd "$THIS_DIR/tmp"

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

  "$PREFIX"/bin/luajit -v
} # === end function

