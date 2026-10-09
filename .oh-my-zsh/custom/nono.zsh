# Preserve Stow links when manually promoting a reviewed nono profile draft.
nono() {
  emulate -L zsh

  if [[ $1 != profile || $2 != promote ]]; then
    command nono "$@"
    return $?
  fi

  local name='' arg
  local -i assume_yes=0 diff_only=0
  for arg in "${@:3}"; do
    case $arg in
      --yes) assume_yes=1 ;;
      --diff) diff_only=1 ;;
      -*) command nono "$@"; return $? ;;
      *)
        if [[ -n $name ]]; then
          command nono "$@"
          return $?
        fi
        name=$arg
        ;;
    esac
  done

  if [[ ! $name =~ '^[[:alnum:]]([[:alnum:]-]*[[:alnum:]])?$' ]]; then
    command nono "$@"
    return $?
  fi

  local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nono"
  local target="$config_dir/profiles/$name.json"
  if [[ ! -L $target ]]; then
    command nono "$@"
    return $?
  fi

  if [[ -n ${NONO_CAP_FILE:-} ]]; then
    print -u2 -- 'nono: promote Stow-managed profiles outside the sandbox'
    return 1
  fi
  if (( assume_yes && diff_only )); then
    print -u2 -- 'nono: --diff cannot be combined with --yes'
    return 1
  fi

  local draft="$config_dir/profile-drafts/$name.json"
  local resolved_target=${target:A}
  if [[ ! -f $target || ! -f $draft || -L $draft ]]; then
    print -u2 -- 'nono: expected an existing profile target and a regular draft file'
    return 1
  fi

  command nono profile validate "$draft" || return $?

  local -i diff_status
  if (( $+commands[delta] )); then
    command diff -u "$resolved_target" "$draft" | command delta --paging=never
    diff_status=$pipestatus[1]
  else
    command git diff --no-index --color=always -- "$resolved_target" "$draft"
    diff_status=$?
  fi
  (( diff_status <= 1 )) || return $diff_status
  (( diff_only )) && return 0

  if (( ! assume_yes )); then
    local answer
    read -r "answer?Apply draft to $resolved_target? [y/N] " || return 1
    [[ $answer == [yY] ]] || return 1
  fi

  command cp "$draft" "$resolved_target" || return $?
  print -- "nono: applied $name to $resolved_target (Stow link preserved; draft retained)"
}
