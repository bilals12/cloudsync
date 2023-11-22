#!/bin/bash -e

# log messages
log() {
    echo "$(date +"%Y-%m-%d %T"): $1"
}

log "starting cloudsync..."

# check if docker image url was provided
if  [$# -lt 1 ]; then
    log "no docker image was provided. usage: ./cloudsync.sh <docker-image-url>"
    exit 1
fi

DOCKER_IMAGE=$1 # get docker image from cli arg

# check for OS type for aws cli installation (assuming linux and macos)
case "$OSTYPE" in
    linux*)
        os="linux"
        arch="x86_64" 
        ;;
    darwin*)
        os="mac"
        # check for ARM architecture
        if [[ `uname -m` == 'arm64' ]]; then
            arch="arm64"
        else
            arch="x86_64"
        fi
        ;;
    *) echo "unsupported OS: $OSTYPE"; exit 1 ;;
esac

# create cloudsync directory if it doesn't exist
if ! test -d cloudsync; then
    log "creating cloudsync directory..."
    mkdir cloudsync
fi

cd cloudsync

# install aws cli if not present
if ! which aws >/dev/null; then
    log "installing aws cli..."
    if [ "$os" = "linux" ]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip" -o "awscliv2.zip"
    elif [ "$os" = "mac" ]; then
        curl "https://awscli.amazonaws.awscli-exe-macos-${arch}.zip" -o "awscliv2.zip"
    fi
    unzip awscliv2.zip && ./aws/install
    rm -rf aws awscliv2.zip
fi

# setup aws creds using environment variables (avoids hardcoding creds)
mkdir -p ~/.aws/
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    log "aws credentials not set. please export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."
    exit 1
fi
cat <<EOS >~/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key_id = $AWS_SECRET_ACCESS_KEY
EOS

# docker login + pull images
# make sure AWS_PROFILE is set or use 'default'
AWS_PROFILE=${AWS_PROFILE:-default}

log "logging into docker..."
aws ecr get-login-password --region eu-west-1 --profile $AWS_PROFILE | docker login --username AWS --password-stdin $(dirname $DOCKER_IMAGE)

log "pulling docker image..."
docker pull $DOCKER_IMAGE

# check for existing docker-compose.yml
if ! test -f docker-compose.yml; then
    log "creating docker-compose.yml..."
    cat <<EOS >docker-compose.yml
# docker-compose configuration goes here
EOS
fi

log "starting docker services..."
docker-compose up -d

log "cloudsync setup complete!"