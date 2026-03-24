# 🚀 Mon Journal d'Apprentissage DevOps

## 👤 Profil
- **Poste actuel** : Lead Tech / Senior Drupal Dev
*Dernière mise à jour : 22 Mars 2026*

---

## ✅ Ce qui est fait

### Infrastructure (Terraform)
- VPC + Subnet + IGW + Security Group
- 2x EC2 Rocky Linux (`t3.small`)
- K3s cluster automatisé via `user_data` + `templatefile()`
- IAM Role + Instance Profile pour les EC2
- SSM Parameter Store pour partager le token K3s
- Remote State Terraform sur S3 + DynamoDB (locking)

### Kubernetes (K3s v1.28.8)
- Cluster 2 nodes (master + worker) opérationnel
- App Node.js/Express déployée sur K3s
- Image Docker sur GHCR (GitHub Container Registry)
- Secret Kubernetes pour puller depuis GHCR
- Ingress Traefik configuré
- App accessible sur http://15.237.175.243/health et /api

### Docker
- App Node.js/Express containerisée
- Image pushée sur GHCR
- `Dockerfile` optimisé avec cache layers

---

## 🔲 Prochaine session

### 1. Finaliser l'accès externe
> Vérifier que http://15.237.175.243/health répond bien depuis l'extérieur

### 2. GitHub Actions CI/CD
```
Push sur main
    └── GitHub Actions
          ├── Build image Docker
          ├── Push sur GHCR
          └── Deploy sur K3s (kubectl apply)
```

### 3. Améliorer l'infra Terraform
- Extraire les scripts `.sh` → déjà fait ✅
- Ajouter `lifecycle { ignore_changes = [user_data] }` → déjà fait ✅
- Créer un module K3s réutilisable

### 4. Migration Homelab (avant 4 Avril)
- Upgrade Proxmox
- Migrer K3s sur VMs locales
- Remote state → Minio (équivalent S3 self-hosted)
- Registry Docker → GHCR (déjà en place ✅)

---

## 📁 Structure du projet

```
devops-learning/
├── terraform/
│   ├── providers.tf      → config Terraform + backend S3
│   ├── variables.tf      → variables
│   ├── main.tf           → infra AWS (VPC, EC2, SG...)
│   ├── iam.tf            → IAM Role + Instance Profile
│   ├── backend.tf        → S3 bucket + DynamoDB (remote state)
│   ├── outputs.tf        → IPs publiques
│   └── scripts/
│       ├── k3s-master.sh → install K3s master + publish token SSM
│       └── k3s-worker.sh → récupère token SSM + join cluster
├── app/
│   ├── index.js          → API Node.js/Express
│   ├── package.json
│   ├── Dockerfile
│   └── .dockerignore
└── k8s/
    ├── deployment.yaml   → 2 replicas, readiness/liveness probes
    ├── service.yaml      → NodePort
    └── ingress.yaml      → Traefik ingress

```

---

## 🔑 Infos importantes

### AWS
- **Region** : eu-west-3 (Paris)
- **Master** : 15.237.175.243 (ip-10-0-1-246)
- **Worker** : 35.180.226.14 (ip-10-0-1-56)
- **K3s version** : v1.28.8+k3s1
- **Free Tier expire** : 4 Avril 2026 → migration Homelab Proxmox

### GHCR
- **Image** : ghcr.io/skeepti/devops-learning-app:1.0.0
- **Secret K8s** : `ghcr-secret`

### Terraform
- **State** : s3://devops-learning-tfstate-2026/dev/terraform.tfstate
- **Lock** : DynamoDB `devops-learning-terraform-lock`

---

## 📚 Concepts appris
- Infrastructure as Code (Terraform)
- AWS VPC, Subnets, Security Groups
- IAM Roles, Policies, Instance Profiles
- SSM Parameter Store
- Remote State S3 + DynamoDB locking
- K3s (Kubernetes léger)
- Docker + Dockerfile optimisé
- GHCR (GitHub Container Registry)
- Kubernetes : Deployment, Service, Ingress, Probes
- Traefik Ingress Controller
- `templatefile()` Terraform
- `lifecycle { ignore_changes }` Terraform

---

## 🗺️ Roadmap complète
- [x] Terraform + AWS ✅
- [x] K3s cluster automatisé ✅
- [x] Docker + GHCR ✅
- [x] Déployer une app sur K3s ✅
- [ ] GitHub Actions CI/CD
- [ ] Migration Homelab Proxmox
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Logging (Loki)
- [ ] Packer (AMI custom)