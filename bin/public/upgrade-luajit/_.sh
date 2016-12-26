
# === {{CMD}}
# === PREFIX is set to ./progs/luajit
upgrade-luajit () {

  local +x ORIGIN="$PWD"
  local +x SRC="luajit"

  export PREFIX

  PREFIX="./progs/luajit"

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
  make         PREFIX="$ORIGIN/$PREFIX"
  make install PREFIX="$ORIGIN/$PREFIX"

  "$ORIGIN/$PREFIX"/bin/luajit -v
} # === end function

