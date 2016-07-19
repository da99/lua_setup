
# === {{CMD}}  path/to/bin
get-version () {
  cd $1; shift
  if [[ -f luajit ]]; then
    ./luajit -v | grep -Po '^LuaJIT \K([\d\.]+)'
    return 0
  fi

  ./lua -v | grep -Po '^Lua \K([\d\.]+)'
} # === end function
