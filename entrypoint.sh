#!/bin/bash

# `-e` ensures the script will exit if any command returns an error
# `-u` and `-o pipefail` for so-called "bash strict mode"
set -eu -o pipefail

# Will force failure if not provided
echo "Building ${CONTAINER}…"
echo "Using repository ${REPOSITORY}"

# These defaults are only set if they were not set by the calling environment
export CONTAINER_TAG=${CONTAINER_TAG:='latest'}
export TEST_SCRIPT=${TEST_SCRIPT:='./test_container.sh'}

# Base container
docker build -t "$CONTAINER:$CONTAINER_TAG" \
  --build-arg AWS_DEFAULT_REGION \
  --build-arg AWS_ACCESS_KEY_ID \
  --build-arg AWS_SECRET_ACCESS_KEY \
  --build-arg AWS_SESSION_TOKEN \
  .

# Run tests
[ -x $TEST_SCRIPT ] && $TEST_SCRIPT

# Authenticate to ECR
aws ecr get-login-password | docker login --username 'AWS' --password-stdin "$REPOSITORY"

# Tag and push
docker tag "$CONTAINER:$CONTAINER_TAG" "$REPOSITORY/$CONTAINER:$CONTAINER_TAG"
docker push "$REPOSITORY/$CONTAINER:$CONTAINER_TAG"