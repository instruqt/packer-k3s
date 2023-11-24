#!/usr/bin/env bash

# This script grabs the latest version of k3s then checks to see 
# if Instruqt already has an official image for that version
# If not, it will use packer and Google auth credentials to make one

GCP_PROJECT='instruqt-support'
K3S_REPO='k3s-io/k3s'

# returns a string like "v1.28.3"
LATEST=$(curl -s https://api.github.com/repos/$K3S_REPO/releases | \
  jq -r 'first(.[].tag_name | select(test("^v[0-9]")))' | cut -d "+" -f 1 )

echo "Latest K3S release: $LATEST"

# turns a string like "v1.28.3" into "v1-28-3"
NEW_VERSION=$( echo $LATEST | sed -r 's/[.]+/-/g' )
#echo $NEW_VERSION

# turns a string like "v1-28-3" into "k3s-v1-28-3"
NEW_VERSION="k3s-$NEW_VERSION"
echo "Looking for: $PROJECT/$NEW_VERSION"

#NEW_VERSION="test-image" # Remove the first # to test the positive case

# Check if the Instruqt image exists. Suppress output from both STDOUT and STDERR because it is noisy.
# If the image does not exist, build it. 
if (! gcloud compute images describe $NEW_VERSION --project $GCP_PROJECT 1>/dev/null 2>/dev/null ); 
then 
    echo "Instruqt image does not exist. Building the image..."
    echo "Image to build: $GCP_PROJECT/$NEW_VERSION"
    # make build make K3S_VERSION=${LATEST}
    packer build -var "k3s_version=${LATEST}" k3s.pkr.hcl
else
    echo "Instruqt image exists. Nothing to do."
fi
