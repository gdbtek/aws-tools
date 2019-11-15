#!/bin/bash -e

function displayUsage()
{
    local -r scriptName="$(basename "${BASH_SOURCE[0]}")"

    echo -e "\033[1;33m"
    echo    "SYNOPSIS :"
    echo    "    ${scriptName}"
    echo    "         --help"
    echo    "         --aws-access-key-id <AWS_ACCESS_KEY_ID>"
    echo    "         --aws-secret-access-key <AWS_SECRET_ACCESS_KEY>"
    echo    "         --region <REGION>"
    echo    "         --bucket <BUCKET>"
    echo    "         --file-path <FILE_PATH>"
    echo    "         --method <METHOD>"
    echo    "         --minute-expire <MINUTE_EXPIRE>"
    echo -e "\033[1;32m"
    echo    "USE CASES :"
    echo    "    If you have a private/public S3 bucket and would like to share the downloadable links to anyone,"
    echo    "    this tool will help to generate signed S3 URLs"
    echo -e "\033[1;35m"
    echo    "DESCRIPTION :"
    echo    "    --help                     Help page"
    echo    "    --aws-access-key-id        AWS Access Key ID (optional, defaults to \${AWS_ACCESS_KEY_ID})"
    echo    "    --aws-secret-access-key    AWS Secret Access Key (optional, defaults to \${AWS_SECRET_ACCESS_KEY})"
    echo    "    --region                   Region (optional, defaults to \${AWS_DEFAULT_REGION})"
    echo    "                               Valid regions: $(getAllowedRegions)"
    echo    "    --bucket                   Bucket name (require)"
    echo    "    --file-path                File path (require)"
    echo    "    --method                   HTTP request method (optional, defaults to '${METHOD}' METHOD)"
    echo    "    --minute-expire            Minutes to expire signed URL (optional, defaults to '${MINUTE_EXPIRE}' minutes)"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ./${scriptName} --help"
    echo    "    ./${scriptName} --bucket 'my_bucket_name' --file-path 'my_path/my_file.txt'"
    echo    "    ./${scriptName} --aws-access-key-id '5KI6IA4AXMA39FV7O4E0' --aws-secret-access-key '5N2j9gJlw9azyLEVpbIOn/tZ2u3sVjjHM03qJfIA' --region 'us-west-1' --bucket 'my_bucket_name' --file-path 'my_path/my_file.txt' --method 'PUT' --minute-expire '30'"
    echo -e "\033[0m"

    exit "${1}"
}

function generateSignURL()
{
    local -r awsAccessKeyID="${1}"
    local -r awsSecretAccessKey="${2}"
    local    region="${3}"
    local -r bucket="${4}"
    local -r filePath="${5}"
    local -r method="${6}"
    local -r minuteExpire="${7}"

    if [[ "${region}" = 'us-east-1' ]]
    then
        region=''
    fi

    local -r endPoint="$("$(isEmptyString "${region}")" = 'true' && echo 's3.amazonaws.com' || echo "s3-${region}.amazonaws.com")"
    local -r expire="$(($(date +'%s') + minuteExpire * 60))"
    local -r signature="$(
        echo -en "${method}\n\n\n${expire}\n/${bucket}/${filePath}" |
        openssl dgst -sha1 -binary -hmac "${awsSecretAccessKey}" |
        openssl base64
    )"
    local -r query="AWSAccessKeyId=$(encodeURL "${awsAccessKeyID}")&Expires=${expire}&Signature=$(encodeURL "${signature}")"

    echo "https://${endPoint}/${bucket}/${filePath}?${query}"
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/libraries/aws.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/libraries/util.bash"

    # Set Default Values

    local awsAccessKeyID="${AWS_ACCESS_KEY_ID}"
    local awsSecretAccessKey="${AWS_SECRET_ACCESS_KEY}"

    REGION="${AWS_DEFAULT_REGION}"
    METHOD='GET'
    MINUTE_EXPIRE='15'

    # Parse Inputs

    local -r optCount="${#}"

    while [[ "${#}" -gt '0' ]]
    do
        case "${1}" in
            --help)
                displayUsage 0
                ;;

            --aws-access-key-id)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    awsAccessKeyID="$(trimString "${1}")"
                    echo
                fi

                ;;

            --aws-secret-access-key)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    awsSecretAccessKey="$(trimString "${1}")"
                fi

                ;;

            --region)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    REGION="$(trimString "${1}")"
                fi

                ;;

            --bucket)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local bucket=''
                    bucket="$(trimString "${1}")"
                fi

                ;;

            --file-path)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    local filePath=''
                    filePath="$(formatPath "$(trimString "${1}")" | sed -e 's/^\///g')"
                fi

                ;;

            --method)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    METHOD="$(trimString "${1}")"
                fi

                ;;

            --minute-expire)
                shift

                if [[ "${#}" -gt '0' ]]
                then
                    MINUTE_EXPIRE="$(trimString "${1}")"
                fi

                ;;

            *)
                shift
                ;;
        esac
    done

    # Validate Inputs

    if [[ "$(isEmptyString "${awsAccessKeyID}")" = 'true' || "$(isEmptyString "${awsSecretAccessKey}")" = 'true' || "$(isEmptyString "${bucket}")" = 'true' || "$(isEmptyString "${filePath}")" = 'true' ]]
    then
        if [[ "${optCount}" -lt '1' ]]
        then
            displayUsage 0
        fi

        error '\nERROR: awsAccessKeyID, awsSecretAccessKey, bucket, or filePath not found\n'
        displayUsage 1
    fi

    if [[ "$(isEmptyString "${REGION}")" = 'true' || "$(isValidRegion "${REGION}")" = 'false' ]]
    then
        fatal "\nFATAL: region must be valid string of $(getAllowedRegions)\n"
    fi

    if [[ "${MINUTE_EXPIRE}" -lt '1' ]]
    then
        fatal '\nFATAL: invalid MINUTE_EXPIRE\n'
    fi

    generateSignURL "${awsAccessKeyID}" "${awsSecretAccessKey}" "${REGION}" "${bucket}" "${filePath}" "${METHOD}" "${MINUTE_EXPIRE}"
}

main "$@"