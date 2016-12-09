

# === {{CMD}}  # defaults to: {{CMD}}  openresty  luarocks
# === {{CMD}}  PREFIX
# === {{CMD}}          openresty  luajit   tarantool  luarocks
# === {{CMD}}  PREFIX  puc openresty  luajit   tarantool  luarocks
# === The PREFIX is set to `$PWD/progs` unless already set.
install () {
  # NOTE: I export PREFIX and LUA_DIR just in case
  # luajit uses them in place of the "--prefix" option
  local +x DEFAULT_PREFIX="$(readlink -m "$PWD/progs")"
  export PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
  if [[ ! -z "$@" &&  -d "$1" ]]; then
    export PREFIX="$1"; shift
  fi

  if [[ -z "$@" ]]; then
    $0 install openresty  luarocks
  else
    for NAME in $@ ; do
      local +x FILE="$THIS_DIR/bin/public/upgrade-$NAME/_.sh"
      if [[ ! -f "$FILE" ]]; then
        sh_color RED "!!! Invalid name: {{$NAME}}"
        exit 0
      fi
      source $FILE
    done

    for NAME in $@ ; do
      upgrade-$NAME "$PREFIX"
    done
  fi

} # === end function


