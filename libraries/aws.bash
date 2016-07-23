#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/util.bash"

#####################
# GENERAL UTILITIES #
#####################

function getAllowedRegions()
{
    echo 'ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 eu-central-1 eu-west-1 sa-east-1 us-east-1 us-west-1 us-west-2'
}

function isValidRegion()
{
    local -r region="${1}"

    local -r allowedRegions=($(getAllowedRegions))

    isElementInArray "${region}" "${allowedRegions[@]}"
}