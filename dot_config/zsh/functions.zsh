# General-purpose shell functions. Ported from the old dotmac
# zplug/functions/ — the employer-specific ones (VPN connect scripts,
# gradle wrapper finder, an old JIRA-prefix commit helper, a raw AWS VPC
# teardown script) were deliberately left behind; see the README for
# where to find them if you still want them.

# Delete every local branch whose upstream is gone (already merged/deleted
# on the remote).
git_prune_branch() {
  if [[ ! -d '.git' ]]; then
    echo "Sorry, not a git repository"
    return 1
  fi
  echo "Updating repository"
  git fetch --all

  local -a lines
  lines=("${(@f)$(git branch -vv | grep -i '\[origin' | grep -v -i '\* main\|\* master')}")
  local l start fields
  for l in $lines[@]; do
    start=("${(s/]/)l}")
    fields=(${(s/ /)start[1]})
    if [[ -n "${fields[4]}" ]]; then
      echo "${fields[1]} --> ${fields[3]:1:-1} (${fields[4]})"
      if [[ "${fields[4]}" == "gone" ]]; then
        git branch -D "${fields[1]}"
        echo "Branch ${fields[1]} removed."
      fi
    fi
  done
}

# `git up` (pull --rebase, autostash on) every git repo found one level
# down from the cwd.
git_pull_all() {
  local i r
  for i in $(find . -name ".git" -type d -depth 2); do
    r="$(dirname "$i")"
    echo "\x1b[33m>>>>>>> Updating $r <<<<<<<<\x1b[0m"
    (cd "$r" && git up)
    if [[ $? -eq 0 ]]; then
      echo "\x1b[32m<<<<<<<<<< DONE >>>>>>>>>\x1b[0m"
    else
      echo "\x1b[31m<<<<<<<<< FAILED >>>>>>>>\x1b[0m"
      break
    fi
  done
}

# `git remote prune origin` every git repo found one level down from the cwd.
git_prune_all() {
  local i r
  for i in $(find . -name ".git" -type d -depth 2); do
    r="$(dirname "$i")"
    echo ">>>>>>> Pruning $r <<<<<<<<"
    (cd "$r" && git remote prune origin)
    echo "<<<<<<<<<< DONE >>>>>>>>>"
  done
}

# Activate the nearest parent virtualenv (walks up from cwd looking for a
# `.Python` marker file).
venv() {
  local home=${HOME}
  local dir=$(pwd)
  while [[ ${dir} != ${home} && ${dir} != "/" ]]; do
    if [[ -e ${dir}/.Python ]]; then
      source ${dir}/bin/activate
      echo "Activated VirtualEnv in '${VIRTUAL_ENV##*/}'"
      return 0
    fi
    dir=$(dirname ${dir})
  done
  echo "No Virtual Env found in '$(pwd)'"
  return 1
}

# Remove stopped containers and dangling (untagged) images.
docker_prune() {
  echo "Removing stopped containers"
  docker rm $(docker ps -a -q -f status=exited) 2>/dev/null
  echo "Removing untagged images"
  docker images -f "dangling=true" -q | xargs -r docker rmi
}
