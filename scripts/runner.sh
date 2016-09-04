#!/usr/bin/env bash

command_name="bench"
command_version="0.0.1-alpha"

_t_clear="\e[0m"

_t_green="\e[32m"
_t_yellow="\e[33m"
_t_red="\e[31m"

_t_default="\e[39m"
_t_highlight1="$_t_green"
_t_highlight2="$_t_yellow"
_t_error="$_t_red"
_t_success="$_t_green"
_t_warning="$_t_yellow"

_g_task_id=""
_g_task_name=""
_g_task_runner=""

_help_description=""
_help_section=""

__help() {

    if [ $# -eq 0 ]; then

        # Banner

        local banner=""

        banner+="${_t_highlight1}${command_name} ${_t_clear}version ${_t_highlight2}${command_version}${_t_clear}"

        # Usage

        local usage=""

        usage+="${_t_highlight2}Usage:${_t_clear}\n"
        usage+="  ${_t_default}${command_name} task [options] [arguments]${_t_clear}"

        # Commands

        local global=""
        local project=""
        local line=""

        local candidates=$(compgen -A function | sort)

        while read candidate; do

            if [[ "$candidate" == "task_"* ]]; then

                local task_id="${candidate:5}";
                local task_help="help_${task_id}"

                _help_description=""
                _help_section="project"

                if type "$task_help" > /dev/null 2>&1; then
                    "$task_help"
                fi

                line=$(printf "  ${_t_highlight1}%-20s ${_t_clear}%s" $(echo "$task_id" | tr '_' ':') "$_help_description")

                if [ "$_help_section" == "project" ]; then
                    project+="${line}\n"
                else
                    global+="${line}\n"
                fi

            fi

        done <<< "$candidates"

        echo -e "${banner}\n"
        echo -e "${usage}\n"

        if [ "$project" != "" ] && [ "$project_path" != ":none:" ]; then
            echo -e "${_t_highlight2}Project:"
            echo -e "${project}"
        fi

        if [ "$global" != "" ]; then
            echo -e "${_t_highlight2}Global:"
            echo -e "${global}"
        fi

    else

        echo "Task Help for ${1}"

    fi
}

__version() {

    echo -e "${_t_highlight1}${command_name} ${_t_clear}version ${_t_highlight2}${command_version}${_t_clear}"
}

__handle_special_global() {

    # Display help when no arguments are passed
    if [ $# -eq 0 ]; then
        __help
        exit
    fi

    # Display help when --help is the only argument
    if [ "$1" == "--help" ]; then
        __help
        exit
    fi

    # Display version when --version is the only argument
    if [ "$1" == "--version" ]; then
        __version
        exit
    fi
}

__handle_special_task() {

    # Task specific help message
    if [ "$1" == "--help" ]; then
        __help "$_g_task_id"
        exit
    fi
}

description() {
    _help_description=$1
}

section() {
    _help_section=$1
}

# Run!

__handle_special_global $@

_g_task_id=$(echo "${1}" | tr ':' '_')
_g_task_name="${1}"
_g_task_runner="task_${_g_task_id}"

shift 1

if type "$_g_task_runner" > /dev/null 2>&1; then
    __handle_special_task $@
    "$_g_task_runner" $@
else
    echo -e "${_t_error}task '$_g_task_name' not found${_t_clear}"
fi