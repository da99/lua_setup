

# === {{CMD}}  # defaults to: {{CMD}}  luarocks
# === {{CMD}}  puc luajit   tarantool  luarocks
# === The PREFIX is set to `./progs`
install () {
  # NOTE: I export PREFIX and LUA_DIR just in case
  # luajit uses them in place of the "--prefix" option
  local +x DEFAULT_PREFIX="./progs"

  export PREFIX="${PREFIX:-$DEFAULT_PREFIX}"

  if [[ -z "$@" ]]; then
    $0 install luarocks
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


