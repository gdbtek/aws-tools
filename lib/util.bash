#!/bin/bash

function error
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
}

function trimString
{
    echo "${1}" | sed -e 's/^ *//g' -e 's/ *$//g'
}

function isEmptyString
{
    if [[ "$(trimString ${1})" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function encodeURL()
{
    local length="${#1}"

    for ((i = 0; i < length; i++))
    do
        local walker="${1:i:1}"

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
