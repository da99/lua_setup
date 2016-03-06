
# === {{CMD}} PREFIX
install-openresty () {
  git_setup clone_or_pull https://github.com/openresty/openresty
  cd /progs/openresty
  LATEST="$(git_setup latest | cut -d'v' -f2-)"

	cd /tmp
  if [[ ! -d openresty-${LATEST} ]]; then
		wget https://openresty.org/download/openresty-${LATEST}.tar.gz
		tar -xvf openresty-${LATEST}.tar.gz
	fi

  cd openresty-${LATEST}

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
