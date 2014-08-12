#!/bin/bash -e

###################
# ARRAY UTILITIES #
###################

function containElementInArray()
{
    local element=''

    for element in "${@:2}"
    do
        [[ "${element}" = "${1}" ]] && echo 'true' && return 0
    done

    echo 'false' && return 1
}

#################
# AWS UTILITIES #
#################

function getAllowRegions()
{
    echo 'ap-northeast-1 ap-southeast-1 ap-southeast-2 eu-west-1 sa-east-1 us-east-1 us-west-1 us-west-2'
}

function isValidRegion()
{
    local region="${1}"
    local regions=($(getAllowRegions))

    echo "$(containElementInArray "${region}" "${regions[@]}")"
}

####################
# STRING UTILITIES #
####################

function encodeURL()
{
    local data
    if [[ $# != 1 ]]; then
        echo "Usage: $0 string-to-urlencode"
        return 1
    fi
    data="$(curl -s -o /dev/null -w %{url_effective} --get --data-urlencode "$1" "")"
    if [[ $? != 3 ]]; then
        echo "Unexpected error" 1>&2
        return 2
    fi
    echo "${data##/?}"
    return 0
}

function error()
{
    echo -e "\033[1;31m${1}\033[0m" 1>&2
}

function fatal()
{
    error "${1}"
    exit 1
}

function formatPath()
{
    local string="${1}"

    while [[ "$(echo "${string}" | grep -F '//')" != '' ]]
    do
        string="$(echo "${string}" | sed -e 's/\/\/*/\//g')"
    done

    echo "${string}" | sed -e 's/\/$//g'
}

function isEmptyString()
{
    if [[ "$(trimString ${1})" = '' ]]
    then
        echo 'true'
    else
        echo 'false'
    fi
}

function trimString()
{
    echo "${1}" | sed -e 's/^ *//g' -e 's/ *$//g'
}
