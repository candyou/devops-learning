#!/bin/bash
# 1. Installer AWS CLI
dnf install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# 2. Attendre que le token soit dans SSM
until /usr/local/bin/aws ssm get-parameter \
  --name "/${project_name}/k3s/node-token" \
  --region ${aws_region} > /dev/null 2>&1; do
  echo "Waiting for token in SSM..."
  sleep 15
done

# 3. Récupérer le token
TOKEN=$(/usr/local/bin/aws ssm get-parameter \
  --name "/${project_name}/k3s/node-token" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region ${aws_region})

# 4. Rejoindre le cluster
curl -sfL https://get.k3s.io | \
  K3S_URL=https://${master_ip}:6443 \
  K3S_TOKEN=$TOKEN \
  sh -

echo "K3s worker joined the cluster"