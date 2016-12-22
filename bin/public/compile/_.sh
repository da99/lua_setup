
# === {{CMD}}
# === Unfinished command to compile scripts into single binary.
compile () {
  local +x IFS=$'\n'
	mkdir -p "$THIS_DIR/bin"
  cd "$THIS_DIR/bin"

  for FILE in $(find "$THIS_DIR"/lua -type f -name "*.lua") ; do
    local +x NAME="$(basename "$FILE" .lua)"
    luastatic  $FILE /lib/libluajit-5.1.a -I /usr/include/luajit-2.0
    rm "$NAME".c
    echo "=== compiled: $NAME"
  done
} # === end function
