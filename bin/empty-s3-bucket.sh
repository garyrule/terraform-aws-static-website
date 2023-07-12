#!/usr/bin/env bash
set -e

bucket_id=$(terraform state show module.site.aws_s3_bucket.site -no-color |grep bucket\  |awk '{print $3}' |tr -d \")
version_data=$(aws s3api get-bucket-versioning --bucket ${bucket_id} |jq '"Status: " + (.Status) + "\nMFADelete: " + (.MFADelete)' |tr -d \")
versioning=$(echo ${version_data} | sed 's/\\n/\n/g' |grep Status |awk '{print $2}')
mfa_delete=$(echo ${version_data} | sed 's/\\n/\n/g' |grep MFA |awk '{print $2}')

echo "Bucket: ${bucket_id}"
echo "Versioning: ${versioning}"

if [[ -n ${mfa_delete} ]];then
	echo "Versioning MFADelete: ${mfa_delete}"
fi

if [[ ${versioning} == "Suspended"  || ${versioning} == "Enabled" ]];then
	echo "Suspended or Enabled"
	object_versions=$(aws s3api list-object-versions --bucket ${bucket_id} --output=json  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')
	if [[ ! $(echo ${object_versions} |jq ".Objects") == 'null' ]];then
		echo "Object Versions to Delete"
		echo ${object_versions} |jq "."
		echo "Deleting Objects"
		aws s3api delete-objects --bucket ${bucket_id} --delete "${object_versions}"
	else
		echo "No Objects"
	fi
else
	echo "Not Versioned"
	aws s3 rm s3://${bucket_id} --recursive
fi
