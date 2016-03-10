
# === {{CMD}} PREFIX
latest-openresty-archive () {
  curl -s "https://openresty.org/" | \
    grep -Pzo "(?s)Lastest release.+?\Kopenresty-[\d\.]+\.tar\.gz" || \
    { bash_setup RED "!!! Failed to get {{latest openresty}} version."; exit 1; }
}

install-openresty () {
  if [[ -z "$@" ]]; then
    bash_setup RED "!!! No {{PREFIX}} specified."
    exit 1
  fi

  LATEST="$(latest-openresty-archive)"

  bash_setup BOLD "=== Downloading {{$LATEST}}... "
	cd /tmp
  if [[ ! -d ${LATEST} ]]; then
    if [[ ! -s $LATEST ]]; then
      wget https://openresty.org/download/${LATEST}
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
