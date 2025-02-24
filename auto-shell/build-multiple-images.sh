#!/bin/bash

# Set Registry & Image Name
REGISTRY="automation.azurecr.io"  # e.g., docker.io/yourusername or ghcr.io/your-org
IMAGE_NAME="uday/alpine"
TOTAL_IMAGES=${1:-5}  # Default to 5 if not provided

# Get the latest tag from the registry (incrementing logic)
get_latest_tag() {
    # Get the latest tag that starts with "test-"
    LATEST_TAG=$(docker images | grep "$REGISTRY/$IMAGE_NAME" | awk '{print $2}' | grep -E '^test-[0-9]+$' | sed 's/test-//' | sort -V | tail -n1)
    
    # If no existing "test-" tag is found, start with 1
    if [[ -z "$LATEST_TAG" ]]; then
        echo 1
    else
        echo $((LATEST_TAG + 1))
    fi
}


# Loop for N images
for ((i=1; i<=TOTAL_IMAGES; i++)); do
    TAG="test-$(get_latest_tag)"
    FILE_CONTENT="This is file for test-$TAG"

    # Create a temporary Dockerfile
    cat <<EOF > Dockerfile
    FROM alpine:latest
    RUN echo "$FILE_CONTENT" > /tmp-$TAG.txt
EOF

    # Build the image
    docker build -t $REGISTRY/$IMAGE_NAME:$TAG .

    # Push the image
    docker push $REGISTRY/$IMAGE_NAME:$TAG

    echo "✅ Successfully built & pushed: $REGISTRY/$IMAGE_NAME:$TAG"
done

# Clean up Dockerfile
rm -f Dockerfile

echo "🎉 Process completed for $TOTAL_IMAGES images!"
