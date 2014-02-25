aws-tools
=========

```
$ ./sign_s3_url.bash -h

SYNOPSIS :
    sign_s3_url.bash -h -m <METHOD> -r <REGION_NAME> -b <BUCKET_NAME> -f <FILE_NAME> -i <AWS_ACCESS_KEY_ID> -s <AWS_SECRET_ACCESS_KEY>

DESCRIPTION :
    -h    Help page
    -m    Method (require)
    -r    Region (optional)
    -b    Bucket name (require)
    -f    File name (require)
    -i    AWS Access Key ID (require)
    -s    AWS Secret Access Key (require)

EXAMPLES :
    sign_s3_url.bash -h
    sign_s3_url.bash -m 'GET' -r 'us-west-1' -b 'my_bucket_name' -f 'my_path/my_file.txt' -i '5KI6IA4AXMA39FV7O4E0' -s 'as3f9jfghihsGIEIGgwigwegjgep02323ffafAFWE'
```
