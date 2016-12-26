
# === {{CMD}}  # Path to luajit or lua in progs/
lua-bin () {
  local +x LUA="$(find -L progs -type f -path "*/bin/luajit" | head -n 1)"

  if [[ -z "$LUA" ]]; then
    local +x LUA="$(find -L progs -type f -path "*/bin/lua" | head -n 1)"
  fi

  echo "$LUA"
} # === end function
