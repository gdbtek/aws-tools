#!/bin/bash -e

function displayUsage()
{
    local scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "         [<S3_RAW_URL>]"
    echo    "         --help"
    echo    "         --region <REGION>"
    echo    "         --bucket <BUCKET_NAME>"
    echo    "         --file-path <FILE_PATH>"
    echo    "         --aws-access-key-id <AWS_ACCESS_KEY_ID>"
    echo    "         --aws-secret-access-key <AWS_SECRET_ACCESS_KEY>"
    echo    "         --method <HTTP_REQUEST_METHOD>"
    echo    "         --minute-expire <MINUTE_TO_EXPIRE>"
    echo -e "\033[1;32m"
    echo    "USE CASES :"
    echo    "    If you have a private/public S3 bucket and would like to share the downloadable links to anyone,"
    echo    "    this tool will help to generate signed S3 URLs"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help                     Help page"
    echo    "    --region                   Region (optional, defaults to \$AWS_DEFAULT_REGION)"
    echo    "                               Valid regions: $(getAllowRegions)"
    echo    "    --bucket                   Bucket name (required if no raw url was passed)"
    echo    "    --file-path                File path (required if no raw url was passed)"
    echo    "    --aws-access-key-id        AWS Access Key ID (optional, defaults to \$AWS_ACCESS_KEY_ID)"
    echo    "    --aws-secret-access-key    AWS Secret Access Key (optional, defaults to \$AWS_SECRET_ACCESS_KEY)"
    echo    "    --method                   HTTP request method (optional, defaults to '${method}' method)"
    echo    "    --minute-expire            Minutes to expire signed URL (optional, defaults to '${minuteExpire}' minutes)"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName} s3://my_bucket_name/my_path/my_file.txt"
    echo    "    ./${scriptName}"
    echo    "        --bucket 'my_bucket_name'"
    echo    "        --file-path 'my_path/my_file.txt'"
    echo    "    ./${scriptName}"
    echo    "        --region 'us-west-1'"
    echo    "        --bucket 'my_bucket_name'"
    echo    "        --file-path 'my_path/my_file.txt'"
    echo    "        --aws-access-key-id '5KI6IA4AXMA39FV7O4E0'"
    echo    "        --aws-secret-access-key '5N2j9gJlw9azyLEVpbIOn/tZ2u3sVjjHM03qJfIA'"
    echo    "        --method 'PUT'"
    echo    "        --minute-expire 30"
    echo -e "\033[0m"

    exit ${1}
}

function generateSignURL()
{
    local region="${1}"
    local bucket="${2}"
    local filePath="${3}"
    local awsAccessKeyID="${4}"
    local awsSecretAccessKey="${5}"
    local method="${6}"
    local minuteExpire="${7}"

    local endPoint="$("$(isEmptyString ${region})" = 'true' && echo 's3.amazonaws.com' || echo "s3-${region}.amazonaws.com")"
    local expire="$(($(date +%s) + ${minuteExpire} * 60))"
    local signature="$(echo -en "${method}\n\n\n${expire}\n/${bucket}/${filePath}" | \
                       openssl dgst -sha1 -binary -hmac "${awsSecretAccessKey}" | \
                       openssl base64)"
    local query="AWSAccessKeyId=$(encodeURL "${awsAccessKeyID}")&Expires=${expire}&Signature=$(encodeURL "${signature}")"

    echo "http://${endPoint}/${bucket}/${filePath}?${query}"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/lib/util.bash" || exit 1

    local optCount=${#}

    local region="${AWS_DEFAULT_REGION}"
    local awsAccessKeyID="${AWS_ACCESS_KEY_ID:-${AWS_ACCESS_KEY}}"
    local awsSecretAccessKey="${AWS_SECRET_ACCESS_KEY:-${AWS_SECRET_KEY}}"
    method='GET'
    minuteExpire=15

    while [[ ${#} -gt 0 ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;
            --region)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local region="$(trimString "${1}")"
                    shift
                fi

                ;;
            --bucket)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local bucket="$(trimString "${1}")"
                    shift
                fi

                ;;
            --file-path)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local filePath="$(formatPath "$(trimString "${1}")" | sed -e 's/^\///g')"
                    shift
                fi

                ;;
            --aws-access-key-id)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local awsAccessKeyID="$(trimString "${1}")"
                    shift
                fi

                ;;
            --aws-secret-access-key)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local awsSecretAccessKey="$(trimString "${1}")"
                    shift
                fi

                ;;
            --method)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local method="$(trimString "${1}")"
                    shift
                fi

                ;;
            --minute-expire)
                shift

                if [[ ${#} -gt 0 ]]
                then
                    local minuteExpire="$(trimString "${1}")"
                    shift
                fi

                ;;
            *)
                local url="$(trimString "${1}")"
                shift
                ;;
        esac
    done

    if [[ "$(isEmptyString ${awsAccessKeyID})" = 'true' || "$(isEmptyString ${awsSecretAccessKey})" = 'true' ]]
    then
        if [[ ${optCount} -gt 0 ]]
        then
            error '\nERROR: aws credentials are missing!\n'
            displayUsage 1
        fi

        displayUsage 0
    fi

    if [[ "$(isEmptyString ${url})" = 'true' &&
          ("$(isEmptyString ${bucket})" = 'true' || "$(isEmptyString ${filePath})" = 'true') ]]
    then
        if [[ ${optCount} -gt 0 ]]
        then
            error '\nERROR: object url (or bucket + path) argument is missing!\n'
            displayUsage 1
        fi

        displayUsage 0
    fi

    if [[ "$(isEmptyString ${bucket})" = 'true' || "$(isEmptyString ${filePath})" = 'true' ]]
    then
        local filePath="${url#s3://*/}"
        local no_protocol="${url#s3://}"
        local bucket="${no_protocol%%/*}"

        if [[ "${filePath})" = "${url}" || "$(isEmptyString ${bucket})" = 'true' ]]
        then
            echo ${bucket}
            echo ${filePath}
            error '\nERROR: raw s3 url argument is invalid!\n'
            displayUsage 1
        fi
    fi

    if [[ ${minuteExpire} < 1 ]]
    then
        fatal '\nFATAL: minuteExpire must be greater than 0!\n'
    fi

    if [[ "$(isEmptyString ${region})" = 'false' && "$(isValidRegion "${region}")" = 'false' ]]
    then
        fatal "\nFATAL: region must be valid string of: $(getAllowRegions)!\n"
    fi

    if [[ "${region}" = 'us-east-1' ]]
    then
        region=""
    fi

    generateSignURL "${region}" "${bucket}" "${filePath}" "${awsAccessKeyID}" "${awsSecretAccessKey}" "${method}" "${minuteExpire}"
}

main "$@"
