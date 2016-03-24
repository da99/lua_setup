
# === {{CMD}} PREFIX
latest-openresty-archive () {
  local VER="$(git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | head -n 1 | cut -d'v' -f1)"
  echo "openresty-${VER}tar.gz"
  return 0
}

install-openresty () {
  local PREFIX_URL="https://openresty.org/download"
  if [[ -z "$@" ]]; then
    bash_setup RED "!!! No {{PREFIX}} specified."
    exit 1
  fi

  local LATEST="$(latest-openresty-archive)"

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

  export PREFIX="$@"
    # --with-http_postgres_module   \
  ./configure                  \
    --prefix="$PREFIX"          \
    --without-http_redis2_module \
    --with-pcre-jit --with-ipv6   \
    -j2
  make
  make install

} # === end function
