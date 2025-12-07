# Developer Quick Start Guide

## 🚀 Creating a New Application

### Step 1: Open Backstage

```bash
# Start Backstage locally
./start-with-env.sh

# Open browser
http://localhost:3000
```

### Step 2: Create Application from Template

1. Click **Create** in the sidebar
2. Select **ArgoCD - Aplicación Hola Mundo**
3. Fill in the form:

#### Application Information
- **Name**: `my-app` (lowercase, hyphens only)
- **Environment**: Choose `dev`, `staging`, or `prod`
- **Description**: Brief description of your app

#### Application Type

**Option A: Custom Application** (with source code)
- Select **Aplicación Custom**
- Choose your language:
  - Node.js
  - Python
  - Java (Spring Boot)
  - Go
  - .NET
- Includes full CI/CD pipeline

**Option B: Prebuilt Image** (existing Docker image)
- Select **Imagen Preconstruida**
- Enter image name: `nginx`, `redis`, etc.
- Enter tag: `latest`, `1.21`, etc.
- No CI/CD needed

#### Deployment Configuration
- **Replicas**: Number of pods (1-10)

#### Repository
- **Owner**: `bcocbo` (or your GitHub org)
- **Repository Name**: Will be created automatically

### Step 3: Review and Create

1. Click **Review**
2. Verify all information
3. Click **Create**

### Step 4: Approve GitOps PR

1. Open the **Pull Request GitOps** link
2. Review the changes:
   - `values/{env}/{app}/values.yaml`
   - `argocd/applications/{env}/{app}.yaml`
3. Approve and merge the PR

### Step 5: Verify Deployment

1. ArgoCD will automatically sync (within 3 minutes)
2. Check status in Backstage:
   - Go to **Catalog**
   - Find your application
   - Check **Overview** tab for ArgoCD card
   - Check **ArgoCD** tab for detailed status
   - Check **Kubernetes** tab for pod status

## 📝 Making Changes

### For Custom Applications (with CI/CD)

```bash
# Clone your repository
git clone https://github.com/bcocbo/my-app.git
cd my-app

# Make changes to your code
# ... edit files ...

# Commit and push
git add .
git commit -m "feat: add new feature"
git push origin main
```

**What happens automatically:**
1. ✅ GitHub Actions runs CI/CD
2. ✅ Builds Docker image
3. ✅ Pushes to Amazon ECR
4. ✅ Creates PR in GitOps repo with new image tag
5. ⏸️ **You approve the PR**
6. ✅ ArgoCD deploys automatically

### For Prebuilt Images

To update the image version:

```bash
# Clone GitOps repository
git clone https://github.com/bcocbo/gitops-apps.git
cd gitops-apps

# Edit values file
vim values/dev/my-app/values.yaml

# Change image tag
image:
  repository: nginx
  tag: 1.22  # Update this

# Commit and push
git add .
git commit -m "chore: update nginx to 1.22"
git push origin main
```

ArgoCD will sync automatically.

## 🔍 Monitoring Your Application

### In Backstage

1. **Overview Tab**
   - ArgoCD sync status
   - Health status
   - Quick links

2. **ArgoCD Tab**
   - Detailed application info
   - Deployment history
   - Resource tree

3. **Kubernetes Tab**
   - Pod status
   - Logs
   - Events

### In ArgoCD UI

```
https://argocd.example.com/applications/my-app
```

### In Kubernetes

```bash
# Check pods
kubectl get pods -n dev -l app=my-app

# Check logs
kubectl logs -n dev -l app=my-app --tail=100

# Describe pod
kubectl describe pod -n dev <pod-name>
```

## 🐛 Troubleshooting

### Application Not Syncing

```bash
# Check ArgoCD application
argocd app get my-app

# Force sync
argocd app sync my-app

# Check sync status
argocd app wait my-app
```

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n dev -l app=my-app

# Check events
kubectl get events -n dev --sort-by='.lastTimestamp'

# Check logs
kubectl logs -n dev <pod-name>

# Describe pod for details
kubectl describe pod -n dev <pod-name>
```

### CI/CD Pipeline Failing

1. Go to GitHub repository
2. Click **Actions** tab
3. Find the failed workflow
4. Check logs for errors
5. Common issues:
   - AWS credentials not configured
   - ECR repository doesn't exist
   - Docker build errors
   - Test failures

### Image Not Updating

1. Check if PR was created in GitOps repo
2. Check if PR was merged
3. Check ArgoCD sync status
4. Force sync if needed:
   ```bash
   argocd app sync my-app
   ```

## 📚 Common Tasks

### Scale Application

```bash
# Edit values file
cd gitops-apps
vim values/dev/my-app/values.yaml

# Change replicas
replicas: 5  # Update this

# Commit and push
git add .
git commit -m "scale: increase replicas to 5"
git push
```

### Change Environment Variables

```bash
# Edit values file
vim values/dev/my-app/values.yaml

# Add environment variables
env:
  - name: LOG_LEVEL
    value: debug
  - name: API_URL
    value: https://api.example.com

# Commit and push
```

### Update Resource Limits

```bash
# Edit values file
vim values/dev/my-app/values.yaml

# Update resources
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Commit and push
```

### Add Ingress

```bash
# Edit values file
vim values/dev/my-app/values.yaml

# Enable ingress
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-app.example.com
      paths:
        - path: /
          pathType: Prefix

# Commit and push
```

### Rollback Deployment

```bash
# Check history
argocd app history my-app

# Rollback to previous version
argocd app rollback my-app <revision-id>

# OR in GitOps repo
git revert <commit-hash>
git push
```

## 🔐 Security Best Practices

### 1. Never Commit Secrets

```bash
# Use Kubernetes secrets instead
kubectl create secret generic my-app-secrets \
  --from-literal=api-key=your-key \
  -n dev

# Reference in values.yaml
envFrom:
  - secretRef:
      name: my-app-secrets
```

### 2. Use Non-Root User

Already configured in the Helm chart:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
```

### 3. Set Resource Limits

Always define resource limits:
```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### 4. Enable Health Checks

Already configured in the Helm chart:
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: http
readinessProbe:
  httpGet:
    path: /ready
    port: http
```

## 📊 Environments

### Development (dev)
- **Auto-sync**: Enabled
- **Prune**: Enabled
- **Self-heal**: Enabled
- **Purpose**: Testing and development

### Staging (staging)
- **Auto-sync**: Enabled
- **Prune**: Enabled
- **Self-heal**: Enabled
- **Purpose**: Pre-production testing

### Production (prod)
- **Auto-sync**: Enabled (with sync window)
- **Prune**: Disabled
- **Self-heal**: Disabled
- **Sync Window**: 2:00 AM - 6:00 AM only
- **Purpose**: Production workloads

## 🎯 Next Steps

1. **Learn GitOps**: Read [GitOps Principles](https://opengitops.dev/)
2. **Explore ArgoCD**: Check [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
3. **Customize Helm Chart**: Review `eks_baseline_chart_Helm`
4. **Set Up Monitoring**: Add Prometheus metrics
5. **Configure Alerts**: Set up notifications

## 📞 Getting Help

- **Documentation**: Check `IMPLEMENTATION_SUMMARY.md`
- **ArgoCD Setup**: See `ARGOCD_SETUP.md`
- **GitOps Setup**: See `GITOPS_SETUP.md`
- **Testing**: See `TEST_TEMPLATE.md`
- **Platform Team**: Contact for support

---

**Happy Coding! 🚀**
