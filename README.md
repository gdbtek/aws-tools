aws-tools
=========

```
$ ./sign_s3_url.bash -h

SYNOPSIS :
    sign_s3_url.bash -h -m <METHOD> -r <REGION_NAME> -b <BUCKET_NAME> -f <FILE_NAME> -i <AWS_ACCESS_KEY_ID> -s <AWS_SECRET_ACCESS_KEY>

DESCRIPTION :
    -h    Help page
    -m    Method (require)
    -r    Region (optional, defaults to $AWS_DEFAULT_REGION or s3.amazonaws.com if neither is given)
    -b    Bucket name (require)
    -f    File name (require)
    -i    AWS Access Key ID (optional, defaults to $AWS_ACCESS_KEY_ID)
    -s    AWS Secret Access Key (optional, defaults to $AWS_SECRET_ACCESS_KEY)

EXAMPLES :
    sign_s3_url.bash -h
    sign_s3_url.bash -m 'GET' -r 'us-west-1' -b 'my_bucket_name' -f 'my_path/my_file.txt' -i '5KI6IA4AXMA39FV7O4E0' -s 'as3f9jfghihsGIEIGgwigwegjgep02323ffafAFWE'
    sign_s3_url.bash -m 'GET' -b 'my_other_bucket' -f 'my_path_a/my_file_2.txt' #uses default AWS_* environment variables
```
