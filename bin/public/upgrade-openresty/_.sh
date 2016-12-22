
# === {{CMD}}

latest-ver () {
  git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | head -n 1 | cut -d'v' -f2
}

current-ver () {
  $PREFIX/nginx/sbin/nginx -v 2>&1 | cut -d'/' -f2 || :
} # current-ver ()

latest-openresty-archive () {
  local VER="$1"; shift
  if [[ -z "$VER" ]]; then
    bash_setup RED "=== Latest OpenResty version {{not found}}."
    exit 1
  fi
  echo ""
  return 0
}

upgrade-openresty () {
  local +x ARCH="$(mksh_setup arch)"

  case "$ARCH" in
    void.x86_64.musl)
      echo "=== Installing packages for NGINX compilation:"
      mksh_setup ignore-exit 6 sudo xbps-install -S \
        make gcc musl-devel \
        pcre-devel libressl-devel zlib-devel ncurses-devel readline-devel \
        curl perl
      ;;
    *)
      echo "!!! Unsupported architecture: $ARCH" >&2
      exit 1
      ;;
  esac

  sh_color BOLD "=== Installing {{OpenResty}}"
  export DEFAULT_PREFIX="$(readlink -m "$PWD/progs")"
  export PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
  if [[ ! -z "$@" ]]; then
    export PREFIX="$1"; shift
  fi

  export LOG_PREFIX="$(readlink -m "$PWD/tmp")"
  mkdir -p "$LOG_PREFIX"

  local +x PREFIX_URL="https://openresty.org/download"

  sh_color BOLD "=== Using PREFIX for OpenResty: {{$PREFIX}}"

  local +x CURRENT_VER=$(current-ver)
  local +x LATEST_VER=$(latest-ver)
  if [[ -z "$LATEST_VER" ]]; then
    exit 1
  fi

  if [[ "$CURRENT_VER" == "$LATEST_VER" ]]; then
    sh_color ORANGE "=== Already {{installed}}: BOLD{{$CURRENT_VER}} in {{$PREFIX}}" >&2
    exit 0
  fi

  local +x LATEST_ARCHIVE="openresty-${LATEST_VER}.tar.gz"
  local +x LATEST_DIR=$(basename "$LATEST_ARCHIVE" ".tar.gz")
  sh_color BOLD "=== Downloading {{$LATEST_ARCHIVE}}... "

  local +x TMP="$THIS_DIR/tmp"
  mkdir -p "$TMP"

	cd "$TMP"

  if [[ ! -d ${LATEST_DIR} ]]; then
    if [[ ! -s $LATEST_ARCHIVE ]]; then
      wget $PREFIX_URL/${LATEST_ARCHIVE}
    fi
		tar -xvf ${LATEST_ARCHIVE} || { rm $LATEST_ARCHIVE; upgrade-openresty "$PREFIX"; exit 0; }
	fi

  cd $LATEST_DIR

  local +x PROCS="$(grep -c '^processor' /proc/cpuinfo)"


  ./configure                      \
    --prefix="$PREFIX"             \
    --with-http_iconv_module       \
    --without-http_redis2_module   \
    --with-pcre-jit                \
    --with-ipv6                    \
    --with-http_ssl_module         \
    --error-log-path="$LOG_PREFIX/startup.error.log" \
    --http-log-path="$LOG_PREFIX/startup.access.log"  \
    -j$(($PROCS - 1))
  make
  make install

} # === end function
