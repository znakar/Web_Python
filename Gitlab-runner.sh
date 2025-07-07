#!/bin/bash

set -e

apt-get update

apt-get install -y curl openssh-server ca-certificates tzdata perl postfix

apt-get install -y postgresql postgresql-contrib redis-server nginx

echo "Downloading latest gitlab-runner"

curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_amd64.deb"

echo "Downloading gitlab-runner-helper-images"

curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner-helper-images.deb"

echo "Setting up GitLab CE repository"

curl "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh" | sudo bash

echo "Installing GitlabCE"

apt-get install -y gitlab-ce

echo "Installing GitLab Runner packages"

dpkg -i gitlab-runner-helper-images.deb

dpkg -i gitlab-runner_amd64.deb

echo "Reconfiguring GitLab Runner"

sudo EXTERNAL_URL="https://gitlab.example.com" apt-get install -y gitlab-ce

echo "Enabling and starting GitLabr runner..."

sudo systemctl enable gitlab-runner
sudo systemctl start gitlab-runner
sudo systemctl status gitlab-runner


echo "Rigestering GitLab Runner"
GITLAB_RUNNER_TOKEN="TOKEN"


gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token "$GITLAB_RUNNER_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner"


