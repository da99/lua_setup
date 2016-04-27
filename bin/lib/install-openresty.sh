
# === {{CMD}}
latest-openresty-archive () {
  local VER="$(git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | head -n 1 | cut -d'v' -f2)"
  if [[ -z "$VER" ]]; then
    bash_setup RED "=== Latest OpenResty version {{not found}}."
    exit 1
  fi
  echo "openresty-${VER}.tar.gz"
  return 0
}

install-openresty () {
  mksh_setup BOLD "=== Installing {{OpenResty}}"
  export PREFIX="$(readlink -m "$PWD/progs")"
  export LOG_PREFIX="$(readlink -m "$PWD/tmp")"
  mkdir -p "$LOG_PREFIX"

  local +x PREFIX_URL="https://openresty.org/download"

  mksh_setup BOLD "=== Using PREFIX for OpenResty: {{$PREFIX}}"

  local +x LATEST="$(latest-openresty-archive)"
  local +x LATEST_DIR=$(basename "$LATEST" ".tar.gz")
  if [[ -z "$LATEST" ]]; then
    exit 1
  fi

  mksh_setup BOLD "=== Downloading {{$LATEST}}... "

  local +x TMP="$THIS_DIR/tmp"
  mkdir -p "$TMP"

	cd "$TMP"

  if [[ ! -d ${LATEST_DIR} ]]; then
    if [[ ! -s $LATEST ]]; then
      wget $PREFIX_URL/${LATEST}
    fi
		tar -xvf ${LATEST} || { rm $LATEST; install-openresty "$PREFIX"; exit 0; }
	fi

  cd $LATEST_DIR

  local PROCS="$(grep -c '^processor' /proc/cpuinfo)"

  ./configure                  \
    --prefix="$PREFIX"          \
    --with-luajit                \
    --with-http_iconv_module      \
    --without-http_redis2_module   \
    --with-pcre-jit                 \
    --with-ipv6                      \
    --error-log-path="$LOG_PREFIX/startup.error.log" \
    --http-log-path="$LOG_PREFIX/startup.access.log"  \
    -j$(($PROCS - 1))
  make
  make install

} # === end function
