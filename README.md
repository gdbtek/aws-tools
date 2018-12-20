# aws-tools

***Sign S3 URL***

```
SYNOPSIS :
    sign_s3_url.bash
        --help
        --aws-access-key-id <AWS_ACCESS_KEY_ID>
        --aws-secret-access-key <AWS_SECRET_ACCESS_KEY>
        --region <REGION>
        --bucket <BUCKET>
        --file-path <FILE_PATH>
        --method <METHOD>
        --minute-expire <MINUTE_EXPIRE>

USE CASES :
    If you have a private/public S3 bucket and would like to share the downloadable links to anyone,
    this tool will help to generate signed S3 URLs

DESCRIPTION :
    --help                     Help page
    --aws-access-key-id        AWS Access Key ID (optional, defaults to ${AWS_ACCESS_KEY_ID})
    --aws-secret-access-key    AWS Secret Access Key (optional, defaults to ${AWS_SECRET_ACCESS_KEY})
    --region                   Region (optional, defaults to ${AWS_DEFAULT_REGION})
                               Valid regions: ap-northeast-1 ap-northeast-2 ap-south-1 ap-southeast-1 ap-southeast-2 ca-central-1 eu-central-1 eu-west-1 eu-west-2 sa-east-1 us-east-1 us-east-2 us-west-1 us-west-2
    --bucket                   Bucket name (require)
    --file-path                File path (require)
    --method                   HTTP request method (optional, defaults to 'GET' METHOD)
    --minute-expire            Minutes to expire signed URL (optional, defaults to '15' minutes)

EXAMPLES :
    ./sign_s3_url.bash --help
    ./sign_s3_url.bash --bucket 'my_bucket_name' --file-path 'my_path/my_file.txt'
    ./sign_s3_url.bash --aws-access-key-id '5KI6IA4AXMA39FV7O4E0' --aws-secret-access-key '5N2j9gJlw9azyLEVpbIOn/tZ2u3sVjjHM03qJfIA' --region 'us-west-1' --bucket 'my_bucket_name' --file-path 'my_path/my_file.txt' --method 'PUT' --minute-expire '30'
```