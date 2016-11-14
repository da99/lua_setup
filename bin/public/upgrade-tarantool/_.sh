
# === {{CMD}}
# === {{CMD}}  install-dir/
upgrade-tarantool () {
  local SRC="$THIS_DIR/tmp/tarantool"

  export PREFIX

  if [[ -z "$@" ]]; then
    PREFIX="$(realpath -m progs/)"
  else
    PREFIX="$1"; shift
  fi

  mksh_setup ORANGE "=== Using prefix: {{$PREFIX}}"
  mkdir -p "$PREFIX/bin"

  if [[ ! -d "$SRC" ]]; then
    git clone https://github.com/tarantool/tarantool.git "$SRC"
    cd "$SRC"
    git submodule init
    git submodule update --recursive
  else
    cd "$SRC"
    local TAG="$(git_setup describe)"
    git pull
    local NEW_TAG="$(git_setup describe)"
  fi

  compile_tarantool "$PREFIX"
} # === end function

compile_tarantool () {
  local PREFIX="$1"; shift
  rm -f CMakeCache.txt
  make clean
  cmake   \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"    \
    -DCMAKE_INSTALL_BINDIR="$PREFIX/bin" \
    -DCMAKE_INSTALL_LIBDIR="$PREFIX/lib"  \
    -DCMAKE_BUILD_TYPE=Release             \
    -DENABLE_DOC=false                      \
    .

  make
  make install # DESTDIR="$PREFIX"
  # mv -i src/tarantool $PREFIX/bin/tarantool
  $PREFIX/bin/tarantool --version
  ln -s $PREFIX/bin/tarantool $PREFIX/bin/lua-tarantool
}
