#!/usr/bin/env bash

. $(dirname $0)/lib/functions.sh
. $(dirname $0)/lib/binaries.sh

set -euo pipefail

JK_VERSION=0.3.0
FOOTLOOSE_VERSION=0.6.2
IGNITE_VERSION=0.5.4
WKSCTL_VERSION=0.8.0

config_backend() {
    sed -n -e 's/^backend: *\(.*\)/\1/p' config.yaml
}

set_config_backend() {
    local tmp=.config.yaml.tmp

    sed -e "s/^backend: .*$/backend: $1/" config.yaml > $tmp && \
        mv $tmp config.yaml && \
        rm -f $tmp
}

git_deploy_key=""
download="yes"
download_force="no"

while test $# -gt 0; do
    case $1 in
    --no-download)
        download="no"
        ;;
    --force-download)
        download_force="yes"
        ;;
    --git-deploy-key)
        shift
        git_deploy_key="--git-deploy-key $1"
        log "Using git deploy key: $1"
        ;;
    *)
        error "unknown argument '$arg'"
        ;;
    esac
    shift
done

if [ $download == "yes" ]; then
    mkdir -p ~/.wks/bin
    export PATH=~/.wks/bin:$PATH
fi

# On macOS, we only support the docker backend.
if [ $(goos) == "darwin" ]; then
    set_config_backend docker
fi

check_command docker
check_version jk $JK_VERSION
check_version footloose $FOOTLOOSE_VERSION
sudo=""
if [ $(config_backend) == "ignite" ]; then
    sudo="sudo env PATH=$PATH";
    check_version ignite $IGNITE_VERSION
fi
check_version wksctl $WKSCTL_VERSION

log "Creating footloose manifest"
jk generate -f config.yaml setup.js

cluster_key="cluster-key"
if [ ! -f "$cluster_key" ]; then
    # Create the cluster ssh key with the user credentials.
    log "Creating SSH key"
    ssh-keygen -q -t rsa -b 4096 -C firekube@footloose.mail -f $cluster_key -N ""
fi

log "Creating virtual machines"
$sudo footloose create

log "Creating Cluster API manifests"
status=footloose-status.yaml
$sudo footloose status -o json > $status
jk generate -f config.yaml -f $status setup.js
rm -f $status

log "Updating container images and git parameters"
wksctl init --git-url=$(git_http_url $(git config --get remote.origin.url)) --git-branch=$(git rev-parse --abbrev-ref HEAD)

log "Pushing initial cluster configuration"
git add config.yaml footloose.yaml machines.yaml flux.yaml wks-controller.yaml

git diff-index --quiet HEAD || git commit -m "Initial cluster configuration"
git push

log "Installing Kubernetes cluster"
wksctl apply --git-url=$(git_http_url $(git config --get remote.origin.url)) --git-branch=$(git rev-parse --abbrev-ref HEAD) $git_deploy_key
wksctl kubeconfig
