aws-tools
=========

```
SYNOPSIS :
    sign_s3_url.bash
         --help
         --region <REGION> --bucket <BUCKET_NAME> --file <FILE_PATH>
         --aws-access-key-id <AWS_ACCESS_KEY_ID> --aws-secret-access-key <AWS_SECRET_ACCESS_KEY>
         --minute-expire <MINUTE_TO_EXPIRE>

DESCRIPTION :
    --help                     Help page
    --region                   Region (optional, defaults to $AWS_DEFAULT_REGION)
                               Valid regions: ap-northeast-1 ap-southeast-1 ap-southeast-2
                                              eu-west-1 sa-east-1
                                              us-east-1 us-west-1 us-west-2
    --bucket                   Bucket name (require)
    --file-path                File path (require)
    --aws-access-key-id        AWS Access Key ID (optional, defaults to $AWS_ACCESS_KEY_ID)
    --aws-secret-access-key    AWS Secret Access Key (optional, defaults to $AWS_SECRET_ACCESS_KEY)
    --minute-expire            Minutes to expire signed URL (optional, defaults to 15 minutes)

EXAMPLES :
    ./sign_s3_url.bash --help
    ./sign_s3_url.bash --bucket 'my_bucket_name' --file-path 'my_path/my_file.txt'
    ./sign_s3_url.bash
        --region 'us-west-1'
        --bucket 'my_bucket_name'
        --file-path 'my_path/my_file.txt'
        --aws-access-key-id '5KI6IA4AXMA39FV7O4E0'
        --aws-secret-access-key '5N2j9gJlw9azyLEVpbIOn/tZ2u3sVjjHM03qJfIA'
        --minute-expire 30
```
