#!/usr/bin/env bash

PROJECT='instruqt-support'
K3S_REPO='k3s-io/k3s'

# returns a string like: "v1.28.3"
LATEST=$(curl -s https://api.github.com/repos/$K3S_REPO/releases | \
  jq -r 'first(.[].tag_name | select(test("^v[0-9]")))' | cut -d "+" -f 1 )

echo "Latest K3S release: $LATEST"

# turns "v1.28.3" into "v1-28-3"
NEW_VERSION=$( echo $LATEST | sed -r 's/[.]+/-/g' )
#echo $NEW_VERSION

# turns "v1-28-3" into "k3s-v1-28-3"
NEW_VERSION="k3s-$NEW_VERSION"
echo "Looking for: $PROJECT/$NEW_VERSION"

#NEW_VERSION="test-image" # Remove the first # to test the positive case

# Check if the Instruqt image exists. Suppress output from both STDOUT and STDERR because it is noisy.
# If the image does not exist, build it. 
if (! gcloud compute images describe $NEW_VERSION --project $PROJECT 1>/dev/null 2>/dev/null ); 
then 
    echo "Instruqt image does not exist. Building the image..."
    echo "Image to build: $PROJECT/$NEW_VERSION"
else
    echo "Instruqt image exists. Nothing to do."
fi
