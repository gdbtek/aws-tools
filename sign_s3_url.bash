#!/bin/bash

function displayUsage()
{
    local scriptName="$(basename ${0})"

    echo -e "\033[1;35m"
    echo    "SYNOPSIS :"
    echo -e "    ${scriptName} -h -m <METHOD> -r <REGION_NAME> -b <BUCKET_NAME> -f <FILE_NAME> -i <AWS_ACCESS_KEY_ID> -s <AWS_SECRET_ACCESS_KEY>\n"
    echo    "DESCRIPTION :"
    echo    "    -h    Help page"
    echo    "    -m    Method (require)"
    echo    "    -r    Region (optional)"
    echo    "    -b    Bucket name (require)"
    echo    "    -f    File name (require)"
    echo    "    -i    AWS Access Key ID (require)"
    echo    "    -s    AWS Secret Access Key (require)"
    echo -e "\033[1;36m"
    echo    "EXAMPLES :"
    echo    "    ${scriptName} -h"
    echo    "    ${scriptName} -m 'GET' -r 'us-west-1' -b 'my_bucket_name' -f 'my_path/my_file.txt' -i '5KI6IA4AXMA39FV7O4E0' -s 'as3f9jfghihsGIEIGgwigwegjgep02323ffafAFWE'"
    echo -e "\033[0m"

    exit 1
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/lib/util.bash" || exit 1

    while getopts ':hm:r:b:f:i:s:' option
    do
        case "${option}" in
            h)
               displayUsage
               ;;
            m)
               local method="${OPTARG}"
               ;;
            r)
               local region="s3-${OPTARG}.amazonaws.com"
               ;;
            b)
               local bucket="${OPTARG}"
               ;;
            f)
               local fileName="${OPTARG}"
               ;;
            i)
               local awsAccessKeyID="${OPTARG}"
               ;;
            s)
               local awsSecretAccessKey="${OPTARG}"
               ;;
            *)
               ;;
        esac
    done

    OPTIND=1

    if [[  "$(isEmptyString ${method})" = 'true' || "$(isEmptyString ${bucket})" = 'true' || "$(isEmptyString ${fileName})" = 'true' || "$(isEmptyString ${awsAccessKeyID})" = 'true' || "$(isEmptyString ${awsSecretAccessKey})" = 'true' ]]
    then
       error 'ERROR: method, bucket, fileName, awsAccessKeyID or awsSecretAccessKey not found!'
       displayUsage
    fi

    local expire="$(($(date +%s) + 900))"
    local signature="$(echo -en "${method}\n\n\n${expire}\n/${bucket}/${fileName}" | openssl dgst -sha1 -binary -hmac "${awsSecretAccessKey}" | openssl base64)"
    local query="AWSAccessKeyId=$(encodeURL "${awsAccessKeyID}")&Expires=${expire}&Signature=$(encodeURL "${signature}")"

    echo "http://${region:="s3.amazonaws.com"}/${bucket}/${fileName}?${query}"
}

main "$@"
