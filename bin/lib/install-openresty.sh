
# === {{CMD}} PREFIX
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
  bash_setup BOLD "=== Installing {{OpenResty}}"
  export PREFIX="$@"
  local PREFIX_URL="https://openresty.org/download"
  if [[ -z "$@" ]]; then
    PREFIX="$PWD/progs"
  fi

  export LOG_PREFIX="$PWD/tmp"
  mkdir -p "$LOG_PREFIX"

  PREFIX="$(realpath -m "$PREFIX")"
  bash_setup BOLD "=== Using PREFIX for OpenResty: {{$PREFIX}}"

  local LATEST="$(latest-openresty-archive)"
  if [[ -z "$LATEST" ]]; then
    exit 1
  fi

  bash_setup BOLD "=== Downloading {{$LATEST}}... "

  local TMP="$THIS_DIR/tmp"
  mkdir -p "$TMP"

	cd "$TMP"
  if [[ ! -d ${LATEST} ]]; then
    if [[ ! -s $LATEST ]]; then
      wget $PREFIX_URL/${LATEST}
    fi
		tar -xvf ${LATEST} || { rm $LATEST; install-openresty "$PREFIX"; exit 0; }
	fi

  cd $(basename ${LATEST} .tar.gz )

  local PROCS="$(grep -c '^processor' /proc/cpuinfo)"
  # --with-http_postgres_module   \

  ./configure                  \
    --prefix="$PREFIX"          \
    --error-log-path="$LOG_PREFIX/startup.error.log" \
    --http-log-path="$LOG_PREFIX/startup.access.log"  \
    --without-http_redis2_module \
    --with-pcre-jit --with-ipv6   \
    -j$(($PROCS - 1))
  make
  make install

} # === end function
