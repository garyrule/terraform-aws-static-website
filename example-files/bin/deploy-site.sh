#!/usr/bin/env bash
set -e

main() {
  syntaxCheck "${@}"

  bucket_search="^bucket_website_id"
  bucket_versioning_search="^bucket_website_versioning_enabled"
  cloudfront_search="cloudfront_distribution_id"

  echo
  echo "This script is provided as a demonstration only"
  echo

  echo "Source dir: ${source_dir} "

  # Get terraform outputs
  tf_output=$(terraform output)

  # Get Bucket ID
  if bucket_id=$(echo "${tf_output}" | grep "${bucket_search}" | awk '{print $3}' | tr -d \"); then
    echo "Bucket ID: ${bucket_id} "
  else
    echo "Unable to find Bucket ID"
    exit 1
  fi


  # Get CloudFront Distribution ID
  if distribution=$(echo "${tf_output}" | grep "${cloudfront_search}" | awk '{print $3}' | tr -d \"); then
    echo "CloudFront Distribution: ${distribution} "
  else
    echo "Couldn't find Distribution"
    exit 1
  fi

  echo

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
    if bucket_versioning=$(echo "${tf_output}" |grep ${bucket_versioning_search}|awk '{print $3}');then
      if [[ "${bucket_versioning}" == "true" ]];then
        echo
        echo "Versioning is enabled; no need to invalidate CloudFront cache"
      else
        echo
        echo "Versioning is not enabled; invalidating CloudFront cache"
        aws cloudfront create-invalidation --distribution-id "${distribution}" --paths "/*" | jq '.Invalidation.Id, .Invalidation.Status'
      fi
    else
      echo "Couldn't get bucket versioning status"
    fi
  fi
}

syntaxCheck() {
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
}

usage() {
  echo
  echo "USAGE"
  echo "-----"
  echo "$0 -s source_dir"
  echo "e.x. $0 -s ~/website/htdocs"
  echo
}

main "$@"
