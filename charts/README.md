# Charts Directory

Este directorio puede contener referencias a charts de Helm.

## Chart Transversal

El chart base utilizado por todas las aplicaciones está en:
- **Repositorio**: https://github.com/bcocbo/eks_baseline_chart_Helm
- **Path**: `.`

## Uso

Las aplicaciones referencian el chart directamente desde su repositorio en las definiciones de ArgoCD Application:

```yaml
source:
  repoURL: https://github.com/bcocbo/eks_baseline_chart_Helm
  targetRevision: HEAD
  path: .
  helm:
    valueFiles:
      - ../../values/dev/my-app/values.yaml
```

## Alternativa: Git Submodule

Si prefieres tener el chart como submodule:

```bash
git submodule add https://github.com/bcocbo/eks_baseline_chart_Helm.git charts/eks-baseline-chart
```

Luego las apps pueden referenciar:
```yaml
source:
  repoURL: https://github.com/bcocbo/gitops-apps
  targetRevision: HEAD
  path: charts/eks-baseline-chart
```
