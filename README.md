# test-app

Aplicación desplegada con ArgoCD y GitOps

## Información del Despliegue

- **Namespace**: `dev`
- **Imagen**: `nginxdemos/hello:latest`
- **Réplicas**: 1

## Despliegue con ArgoCD

Esta aplicación se despliega automáticamente usando ArgoCD y GitOps.

### Verificar el Estado

```bash
# Ver el estado de la aplicación en ArgoCD
argocd app get test-app

# Ver los pods desplegados
kubectl get pods -n dev -l app=test-app

# Ver los logs
kubectl logs -n dev -l app=test-app --tail=50
```

### Acceder a la Aplicación

```bash
# Port forward para acceso local
kubectl port-forward -n dev svc/test-app 8080:80

# Luego visita: http://localhost:8080
```

## Actualizar la Aplicación

Para actualizar la aplicación, modifica los values en el repositorio GitOps y ArgoCD sincronizará automáticamente los cambios.

---
Generado por Backstage Software Templates
