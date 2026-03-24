#!/bin/bash
# 1. Installer AWS CLI
dnf install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# 2. Installer K3s
curl -sfL https://get.k3s.io | sh -

# 3. Attendre que le token existe
until [ -f /var/lib/rancher/k3s/server/node-token ]; do
  echo "Waiting for K3s token..."
  sleep 5
done

# 4. Publier le token dans SSM
TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)
/usr/local/bin/aws ssm put-parameter \
  --name "/${project_name}/k3s/node-token" \
  --value "$TOKEN" \
  --type "SecureString" \
  --overwrite \
  --region ${aws_region}

echo "K3s master ready, token published to SSM"