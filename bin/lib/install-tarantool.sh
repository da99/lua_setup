
# === {{CMD}} ...
install-tarantool () {
  local SRC="$THIS_DIR/tmp/tarantool"

  export PREFIX

  if [[ -z "$@" ]]; then
    PREFIX="$(realpath -m progs/)"
  else
    PREFIX="$1"; shift
  fi

  mkdir -p "$PREFIX/bin"

  if [[ ! -d "$SRC" ]]; then
    git clone https://github.com/tarantool/tarantool.git "$SRC"
    cd "$SRC"
    git submodule init
    git submodule update --recursive
    compile_tarantool "$PREFIX"
  else
    cd "$SRC"
    local TAG="$(git_setup describe)"
    git pull
    local NEW_TAG="$(git_setup describe)"
    if [[ "$NEW_TAG" != "$TAG" ]]; then
      compile_tarantool "$PREFIX"
    fi
  fi

} # === end function

compile_tarantool () {
  local PREFIX="$1"; shift
  rm -f CMakeCache.txt
  cmake . -DCMAKE_BUILD_TYPE=RelWithDebInfo -DENABLE_DOC=false
  make
  mv -i src/tarantool $PREFIX/bin/tarantool
  $PREFIX/bin/tarantool --version
}
