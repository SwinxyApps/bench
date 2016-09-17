#!/usr/bin/env bash

# Project :: Task :: start

help_start() {
    section "project"
    description "Start project containers with links to proxy/dns services."
}
task_start() {
    docker-compose up -d
    proxy
}

# Project :: Task :: stop

help_stop() {
    section "project"
    description "Stop project containers."

}
task_stop() {
    docker-compose stop
}

# Project :: Task :: clean

help_clean() {
    section "project"
    description "Stop and remove project containers."
}
task_clean() {
    task_stop
    docker-compose rm -f
}

# Project :: Task :: reload

help_reload() {
    section "project"
    description "Alias to stop, remove and then start the containers."
}
task_reload() {
    task_clean
    task_start
}

# Global :: Task :: self-update

help_self-update() {
    section "global"
    description "Update bench and current stacks to latest versions."
}
task_self-update()
{
    git -C "${HOME}/.bench" pull
}

# Global :: Task :: enable

help_enable() {
    section "global"
    description "Enable dns/proxy on the host system."
}
task_enable() {
    docker-compose -f $HOME/.bench/docker-compose.yml up -d
}

# Global :: Task :: disable

help_disable() {
    section "global"
    description "Disable bench."
}
task_disable() {
    docker-compose -f $HOME/.bench/docker-compose.yml stop
}

# Global :: Task :: bootstrap

help_bootstrap() {
    section "global"
    description "Initialize a new project."

}
task_bootstrap() {

    local stack="${HOME}/.bench/stack/${1}"
    local repository="git://github.com/SwinxyApps/bench-stack-${1}.git"

    # Keep our local copy of the stack up to date
    # TODO: tie in with self-update command

    if [ -d "$stack" ]; then
        git -C "$stack" pull
    else
        git clone --depth=1 --branch=master $repository $stack
    fi

    # Create the project using the stack as a template

    cp -ap $stack $2

    # Replace bench.sh

    rm -rf "${2}/.git"
    printf "#!/bin/bash\n\n# Source Stack Commands\n. ~/.bench/stack/${1}/bench.sh\n\n# Project Commands Here" > "${2}/bench.sh"

    # Rewrite Variables

    sedi "s/\${project.name}/${2}/g" "${2}/docker-compose.yml"

    # Pass on to the stack specific bootstrap

    cd $2
    bench bootstrap
}