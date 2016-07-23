#!/bin/bash -e

###################
# ARRAY UTILITIES #
###################

function isElementInArray()
{
    local -r element="${1}"

    local walker=''

    for walker in "${@:2}"
    do
        [[ "${walker}" = "${element}" ]] && echo 'true' && return 0
    done

    echo 'false' && return 1
}

####################
# STRING UTILITIES #
####################

function encodeURL()
{
    local -r url="${1}"

    local i=0
    local walker=''

    for ((i = 0; i < ${#url}; i++))
    do
        walker="${url:i:1}"

        case "${walker}" in
            [a-zA-Z0-9.~_-])
                printf "${walker}"
                ;;
            ' ')
                printf +
                ;;
            *)
                printf '%%%X' "'${walker}"
                ;;
        esac
    done
}

function error()
{
    local -r message="${1}"

    echo -e "\033[1;31m${message}\033[0m" 1>&2
}

function fatal()
{
    local -r message="${1}"

    error "${message}"
    exit 1
}

function formatPath()
{
    local path="${1}"

    while [[ "$(grep -F '//' <<< "${path}")" != '' ]]
    do
        path="$(sed -e 's/\/\/*/\//g' <<< "${path}")"
    done

    sed -e 's/\/$//g' <<< "${path}"
}

function isEmptyString()
{
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function trimString()
{
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}