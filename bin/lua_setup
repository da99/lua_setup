#!/usr/bin/env bash
#
#
THE_ARGS="$@"
THIS_DIR="$(bash_setup dirname_of_bin "$0")"

if [[ -z "$@" ]]; then
  action="watch"
else
  action=$1
  shift
fi

set -u -e -o pipefail

case $action in
  help|--help)
    bash_setup print_help $0
    ;;

  watch)
    cmd () {
      if [[ -z "$@" ]]; then
        path="some.file"
      else
        path="$1"
        shift
      fi
    }
    cmd

    echo -e "\n=== Watching: $files"
    while read -r CHANGE; do
      dir=$(echo "$CHANGE" | cut -d' ' -f 1)
      path="${dir}$(echo "$CHANGE" | cut -d' ' -f 3)"
      file="$(basename $path)"

      # Make sure this is not a temp/swap file:
      { [[ ! -f "$path" ]] && continue; } || :

      # Check if file has changed:
      if bash_setup is_same_file "$path"; then
        echo "=== No change: $CHANGE"
        continue
      fi

      # File has changed:
      echo -e "\n=== $CHANGE ($path)"

      if [[ "$path" =~ "$0" ]]; then
        echo "=== Reloading..."
        break
      fi

      if [[ "$file" =~ ".some_ext" ]]; then
        cmd $path
      fi
    done < <(inotifywait --quiet --monitor --event close_write some_file "$0") || exit 1
    $0 watch $THE_ARGS
    ;;

  *)
    func_file="$THIS_DIR/bin/lib/${action}.sh"
    if [[ -s "$func_file" ]]; then
      source "$func_file"
      "$action" $@
      exit 0
    fi

    # === It's an error:
    echo "!!! Unknown action: $action" 1>&2
    exit 1
    ;;

esac
