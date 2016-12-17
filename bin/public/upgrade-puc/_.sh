
# === {{CMD}}
# === {{CMD}}  PREFIX
upgrade-puc () {
  export PREFIX

  if [[ -z "$@" ]]; then
    PREFIX="$(realpath -m progs)"
  else
    PREFIX="$(realpath -m "$1")"; shift
  fi
  mkdir -p "$PREFIX"

  local URL="https://www.lua.org"
  local PARTIAL=$(wget -q -O- $URL/download.html | grep -iPzo 'HREF="\K(.+?)(?=">source<)')
  local NAME=$(basename $PARTIAL .tar.gz)

  if [[ -f "$PREFIX/bin/lua" ]]; then
    local +x CURRENT="$($0 get-version "$PREFIX/bin")"
    if [[ "$NAME" == "lua-$CURRENT" ]]; then
      sh_color ORANGE "=== Already {{installed}}: $CURRENT" >&2
      return 0
    fi
  fi

  local TMP="$THIS_DIR/tmp"
  local ARCHIVE="$TMP/${NAME}.tar.gz"
  local SOURCE="$TMP/$NAME"

  mkdir -p $TMP
  cd $TMP

  if [[ ! -s $ARCHIVE ]]; then
    download $URL/$PARTIAL
  fi

  rm -rf $NAME
  tar zxf $ARCHIVE


  sed -i "s|/usr/local|$PREFIX|" "$NAME/src/luaconf.h"
  cd "$NAME"
  make linux test

  make install INSTALL_TOP="$PREFIX"

  set '-x'
  $PREFIX/bin/lua -v
} # === end function

download () {
  local URL="$1"; shift
  local ARCHIVE="$(basename $URL)"
  rm -f $ARCHIVE
  wget $URL -O $ARCHIVE
}
