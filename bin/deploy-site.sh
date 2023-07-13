#!/usr/bin/env bash
set -e

main() {
  syntaxCheck "${@}"

  echo "This script is provided as a demonstration and will work for a deployment example included with this repository"
  echo "HOWEVER: It may not work for your specific needs and evaluating that is left to you"
  echo

  echo -n "Source dir: ${source_dir} "

  # Get terraform outputs
  tf_output=$(terraform output)

  # Get Bucket ID
  if bucket_id=$(echo "${tf_output}" | grep bucket-id | awk '{print $3}' | tr -d \"); then
    echo -n "Bucket ID: ${bucket_id} "
  else
    echo "Unable to find Bucket ID"
    exit 1
  fi

  # Get Cloudfront Distribution ID
  if distribution=$(echo "${tf_output}" | grep cloudfront-distribution-id | awk '{print $3}' | tr -d \"); then
    echo -n "Cloudfront Distribution: ${distribution} "
  else
    echo "Couldn't find Distribution"
    exit 1
  fi

  # Sync Files
  cd "${source_dir}"
  sync_output=$(aws s3 sync . s3://"${bucket_id}")

  # Check Output
  if [[ -z ${sync_output} ]]; then
    echo "Nothing to do"
    exit 0
  else
    echo "Copying files from ${source_dir} to s3://${bucket_id}"
    echo "${sync_output}"
  fi

  echo "Invalidating Cloudfront Cache"
  aws cloudfront create-invalidation --distribution-id "${distribution}" --paths "/*" | jq '.Invalidation.Id, .Invalidation.Status'
}

syntaxCheck() {
  ### PARSE OPTIONS
  while getopts "hs:" options; do
    case $options in
    s) source_dir=$OPTARG ;;
    h) usage ;;
    *) usage ;;
    esac
  done

  if [[ -z "${source_dir}" ]]; then
    usage
    echo "-s switch is mandatory"
    exit 1
  fi

  if [[ ! -d "${source_dir}" ]]; then
    echo "${source_dir} not a directory"
    exit 1
  fi

  if [[ ! -f "${source_dir}/index.html" ]]; then
    echo "Source directory does not have required index.html file present"
    exit 1
  fi
  if [[ ! -f "${source_dir}/error.html" ]]; then
    echo "Source directory does not have required error.html file present"
    exit 1
  fi
}

usage() {
  echo "USAGE"
  echo "-----"
  echo "$0 -s source_dir"
  echo "e.x. $0 -s ~/website_files/mywebsite"
  echo
}

main "$@"
