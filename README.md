# GitOps Apps Repository

Repositorio centralizado para la configuración de despliegue de aplicaciones usando GitOps con ArgoCD.

## Estructura

```
gitops-apps/
├── charts/                    # Referencias a charts de Helm
│   └── README.md
├── values/                    # Valores específicos por aplicación y entorno
│   ├── dev/
│   ├── staging/
│   └── prod/
├── argocd/                    # Configuración de ArgoCD
│   ├── app-of-apps.yaml      # App of Apps principal
│   ├── projects/             # Proyectos de ArgoCD por entorno
│   │   ├── dev-project.yaml
│   │   ├── staging-project.yaml
│   │   └── prod-project.yaml
│   └── applications/         # Definiciones de aplicaciones
│       ├── dev/
│       ├── staging/
│       └── prod/
└── README.md
```

## Flujo de Trabajo

### 1. Creación de Nueva Aplicación

Cuando se crea una nueva aplicación desde Backstage:

1. **Backstage Template** crea un PR con:
   - `values/{environment}/{app-name}/values.yaml` - Configuración específica de la app
   - `argocd/applications/{environment}/{app-name}.yaml` - Definición de ArgoCD Application

2. **Revisar y Aprobar** el PR

3. **ArgoCD detecta** los cambios automáticamente y despliega la aplicación

### 2. Actualización de Imagen

Cuando el CI/CD construye una nueva imagen:

1. **GitHub Actions** actualiza automáticamente el `imageTag` en `values/{env}/{app}/values.yaml`
2. **ArgoCD detecta** el cambio y sincroniza el despliegue
3. **Kubernetes** actualiza los pods con la nueva imagen

## Entornos

### Development (dev)
- **Namespace**: `dev`
- **Sync Policy**: Automático con self-heal
- **Recursos**: Límites bajos para desarrollo

### Staging (staging)
- **Namespace**: `staging`
- **Sync Policy**: Automático con self-heal
- **Recursos**: Similares a producción

### Production (prod)
- **Namespace**: `prod`
- **Sync Policy**: Manual o con aprobaciones
- **Recursos**: Configuración optimizada para producción

## Chart Transversal

Todas las aplicaciones usan el chart base:
- **Repositorio**: https://github.com/bcocbo/eks_baseline_chart_Helm
- **Path**: `.`

El chart proporciona:
- Deployment con security best practices
- Service, Ingress, HPA
- ConfigMap y Secret support
- Probes configurables

## Ejemplo de Values

```yaml
# values/dev/my-app/values.yaml
replicaCount: 2

image:
  repository: ghcr.io/bcocbo/my-app
  tag: "sha-abc123"
  pullPolicy: Always

service:
  type: ClusterIP
  port: 80
  targetPort: 3000

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: my-app-dev.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

## Ejemplo de ArgoCD Application

```yaml
# argocd/applications/dev/my-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: dev
  source:
    repoURL: https://github.com/bcocbo/eks_baseline_chart_Helm
    targetRevision: HEAD
    path: .
    helm:
      valueFiles:
        - https://raw.githubusercontent.com/bcocbo/gitops-apps/main/values/dev/my-app/values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## Mantenimiento

### Actualizar Chart Transversal

Para actualizar todas las apps a una nueva versión del chart:

1. Actualizar `targetRevision` en las Applications
2. Commit y push
3. ArgoCD sincronizará automáticamente

### Rollback

Para hacer rollback de una aplicación:

```bash
# Revertir el commit que cambió el imageTag
git revert <commit-hash>
git push origin main

# O manualmente editar values.yaml con el tag anterior
```

## Seguridad

- ✅ Repositorio público para configuración (sin secretos)
- ✅ Secretos manejados por Kubernetes Secrets o External Secrets Operator
- ✅ Revisión de PRs requerida antes de merge
- ✅ Protección de branch `main`

## Soporte

Para issues o preguntas, contacta al Platform Team.
