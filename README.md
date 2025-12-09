# test-app02

Aplicación desplegada con ArgoCD y GitOps

## Información del Despliegue

- **Tipo**: prebuilt
- **Namespace**: `dev`
- **Entorno**: `dev`

- **Imagen**: `nginxdemos/hello:latest`

- **Réplicas**: 1

## Despliegue con ArgoCD

Esta aplicación se despliega automáticamente usando ArgoCD y GitOps.

### Verificar el Estado

```bash
# Ver el estado de la aplicación en ArgoCD
argocd app get test-app02

# Ver los pods desplegados
kubectl get pods -n dev -l app=test-app02

# Ver los logs
kubectl logs -n dev -l app=test-app02 --tail=50
```

### Acceder a la Aplicación

```bash
# Port forward para acceso local
kubectl port-forward -n dev svc/test-app02 8080:80

# Luego visita: http://localhost:8080
```


## Actualizar la Aplicación

Esta aplicación usa una imagen preconstruida. Para actualizar:

1. Modifica el `imageTag` en el [repositorio GitOps](https://github.com/bcocbo/gitops-apps/tree/main/values/dev/test-app02)
2. ArgoCD detectará el cambio y desplegará la nueva versión automáticamente



---
Generado por Backstage Software Templates
