#!/usr/bin/env bash

# up_search <file>
#
# Iterates up from the CWD to find the given file.
#
up_search() {

  local slashes=${PWD//[^\/]/}
  local directory="$PWD"

  for (( n=${#slashes}; n>0; --n ))
  do
    test -e "$directory/$1" && __="$directory" && return
    directory="$directory/.."
  done

  return 1
}

# import <stack>
#
# Ensures the given stack is downloaded and sources
# its bench.sh file.
#
import() {

    local stack="${HOME}/.bench/stack/${1}"

    if [ ! -d "${stack}" ]; then
        git clone --depth=1 --branch=master git://github.com/SwinxyApps/bench-stack-${1}.git "$stack"
    fi

    . "${stack}/bench.sh"
}

# proxy
#
# Adds the nginx service to the proxy
#
proxy() {

    if [ -z $(docker ps -q -f name=bench-proxy) ]
      then

        task_enable

    fi

    echo "setting up $proxy network connection"

    local network=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project" }}' $(docker-compose ps -q nginx))_default
    local enabled=$([ -z "$(docker network inspect --format "{{ .Containers }}" $network | grep bench-proxy)" ] && echo 0 || echo 1)

    if [ "$enabled" -eq 0 ]
      then

        echo " - connecting bench-proxy to $network"

        docker network connect $network bench-proxy

        # ISSUE/TODO
        #
        # The initial config created by nginx-proxy is invalid, the network connect will not trigger the config to be
        # generated so we stop/start as well.

        docker-compose stop nginx
        docker-compose start nginx

        echo " - done."

    else

        echo " - network $network already connected to bench-proxy"

    fi
}