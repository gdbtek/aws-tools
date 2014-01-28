#!/bin/bash

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

function signS3URL()
{
    local expire="$(($(date +%s) + 900))"
    local signature="$(echo -en "${1}\n\n\n${expire}\n/${2}/${3}" | openssl dgst -sha1 -binary -hmac "${5}" | openssl base64)"
    local query="Expires=${expire}&AWSAccessKeyId=$(encodeURL "${4}")&Signature=$(encodeURL "${signature}")"

    echo "http://s3.amazonaws.com/${2}/${3}?${query}"
}

signS3URL "$@"
