#!/usr/bin/env bash


## If no bucket name is passed, prompt user to enter one from their account.
## Else, assign $1 to bucket_name.
get_bucket_name () {
  if [[ $# -eq 0 ]]; then
    echo
    echo "$buckets"
    echo
    read -p "Enter a bucket name: " bucket_name
  else
    bucket_name=$1
  fi
}

## Validate bucket name. Exit if invalid.
validate_bucket_name() {
  bucket=$(echo "$bucket_name" | tr '[:upper:]' '[:lower:]')
  for i in $buckets; do
    if [[ $i == $bucket ]]; then
      valid=true
      break
    else
      valid=false
    fi
  done

  if [[ $valid == true ]]; then
    :
  else
    echo
    echo "Invalid bucket name. Exiting..."
    exit 1
  fi
}

## Get Total Objects and Total Size of bucket root.
get_root_size() {
  ls_root=$(aws s3 ls s3://$bucket --human-readable --summarize)
  echo
  echo "s3://$bucket"
  echo "$(echo "$ls_root" | grep 'Total Objects: ')"
  echo "$(echo "$ls_root" | grep 'Total Size: ')"
}

## Get all directories in S3 bucket, along with Total Objects and Total Size.
get_all_dirs() {
  all_dirs=$(aws s3 ls s3://$bucket --recursive | grep '/$' | awk '{print $4}')
  for i in $all_dirs; do
    ls_dir=$(aws s3 ls s3://$bucket/$i --human-readable --summarize)
    echo
    echo "s3://$bucket/$i"
    echo "$(echo "$ls_dir" | grep 'Total Objects: ')"
    echo "$(echo "$ls_dir" | grep 'Total Size: ')"
  done
}



# ============================================================================ #
## Set var 'buckets' to list of buckets.
buckets=$(aws s3 ls | awk '{print $3}')
get_bucket_name $1
validate_bucket_name
get_root_size
get_all_dirs
