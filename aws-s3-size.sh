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

## Assign directories in bucket_root to bucket_dirs
get_bucket_dirs() {
  bucket_dirs=$(echo "$bucket_root" | grep ' PRE ' | sed 's/^[[:space:]]*//g' | sed 's/\/$//g' | awk '{print $2}')
  echo
  echo "The following directories were found: "
  echo "$bucket_dirs"
}

## Get total bytes of all files
total_bytes() {
  total=0
  for i in $objects; do
    total=$(( $total + $i ))
  done
}

## Convert (and output) bytes accordingly
convert_bytes() {
  if [[ $total -ge $(( 1024 ** 6 )) ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 6)) )) EiB"
  elif [[ $total -ge $(( 1024 ** 5 )) ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 5)) )) PiB"
  elif [[ $total -ge $(( 1024 ** 4 )) ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 4)) )) TiB"
  elif [[ $total -ge $(( 1024 ** 3 )) ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 3)) )) GiB"
  elif [[ $total -ge $(( 1024 ** 2 )) ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 2)) )) MiB"
  elif [[ $total -ge $(( 1024 ** 1 ))  ]]; then
    echo
    echo "Total Size: $(( $total / $((1024 ** 1)) )) KiB"
  elif [[ $total -ge 2 ]]; then
    echo
    echo "Total Size: $total bytes"
  elif [[ $total -eq 1 ]]; then
    echo
    echo "Total Size: $total byte"
  elif [[ $total -eq 0 ]]; then
    echo
    echo "Total Size: $total bytes"
  fi
}

# ============================================================================ #
## Set var 'buckets' to list of buckets.
buckets=$(aws s3 ls | awk '{print $3}')

get_bucket_name $1
validate_bucket_name

## Assign bucket object contents to bucket_root
bucket_root=$(aws s3 ls s3://$bucket --summarize)
#get_bucket_dirs ## WIP

## Assign files (not directories) to var objects
objects=$(echo "$bucket_root" | grep '-' | awk '{print $3}')

total_bytes
convert_bytes
