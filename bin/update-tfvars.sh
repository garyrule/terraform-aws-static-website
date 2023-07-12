#!/usr/bin/env bash
set -e

for example in $(find ./*  -maxdepth 0 -type d);do
	echo ${example}
	cd ${example}
	terraform-docs tfvars hcl . --output-file blah
	cd -
done
