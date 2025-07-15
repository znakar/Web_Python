#!/bin/bash

set -e

echo "[*] Updating system..."

apt-get update

echo "[*] Installing prerequisities..."

apt-get install -y curl openssh-server ca-certificates tzdata perl postfix

echo "[*] Installing GitLab dependencies (Postgres, Redis, Nginx)..."

apt-get install -y postgresql postgresql-contrib redis-server nginx

echo "[*] Setting up GitLab CE repository..."

curl "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh" | sudo bash

echo "[*] Downloading GitLab Runner packages..."

curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner_amd64.deb"
curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/deb/gitlab-runner-helper-images.deb"


echo "[*] Installing GitLab Runner packages"
dpkg -i gitlab-runner-helper-images.deb
dpkg -i gitlab-runner_amd64.deb || apt-get install -f -y


echo "[*] Enabling and starting GitLabr runner..."

sudo systemctl enable gitlab-runner
sudo systemctl start gitlab-runner
sudo systemctl status gitlab-runner


echo "[*] Rigestering GitLab Runner..."
read -p "Enter your GitLab Runner registration token: " GITLAB_RUNNER_TOKEN


gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --token "$GITLAB_RUNNER_TOKEN" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner"


echo "[+] Done! GitLab CE and Runner are installed and registered."
