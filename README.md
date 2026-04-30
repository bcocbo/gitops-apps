# GitOps Apps — Repositorio de Configuración

Repositorio central de configuración GitOps para todas las aplicaciones desplegadas con ArgoCD.

## Estructura

```
gitops-apps/
├── argocd/
│   ├── app-of-apps.yaml              # App-of-Apps (escanea applications/ y projects/)
│   ├── applications/
│   │   ├── dev/                       # Applications de desarrollo
│   │   │   └── tes-app-123.yaml
│   │   ├── staging/                   # Applications de staging
│   │   ├── prod/                      # Applications de producción
│   │   └── preview/                   # ApplicationSet para ambientes efímeros
│   │       └── applicationset-preview.yaml
│   └── projects/
│       ├── dev-project.yaml           # Namespaces: dev, dev-*
│       ├── staging-project.yaml       # Namespaces: staging, staging-*
│       ├── prod-project.yaml          # Namespaces: prod, prod-*
│       └── preview-project.yaml       # Namespaces: preview-*
├── values/
│   ├── dev/{app-name}/values.yaml     # Values por app en dev
│   ├── staging/                       # Values por app en staging
│   ├── prod/                          # Values por app en producción
│   └── preview/values.yaml            # Values base para TODOS los previews
├── charts/
│   └── README.md                      # Referencia al chart transversal
└── .github/
    └── workflows/
        └── ci.yaml                    # CI del repo gitops (no de las apps)
```

## Cómo funciona

### App-of-Apps

El `app-of-apps.yaml` escanea recursivamente `argocd/applications/` y aplica todos los manifiestos que encuentra. Cualquier archivo YAML que pongas ahí se convierte en una Application de ArgoCD automáticamente.

### Multi-Source Pattern

Cada Application usa dos sources:
1. **Chart transversal** (`eks_baseline_chart_Helm`) — la plantilla Helm compartida
2. **Este repo** (`ref: values`) — los values específicos por app/ambiente

```yaml
sources:
  - repoURL: https://github.com/bcocbo/eks_baseline_chart_Helm
    targetRevision: HEAD
    path: .
    helm:
      valueFiles:
        - $values/values/dev/{app-name}/values.yaml
  - repoURL: https://github.com/bcocbo/gitops-apps
    targetRevision: HEAD
    ref: values
```

### Projects y Sync Windows

Cada ambiente tiene un AppProject que controla:
- **Namespaces permitidos** — qué namespaces puede crear/usar
- **Source repos** — de dónde puede leer
- **Sync Windows** — cuándo se permite sincronizar

| Proyecto | Namespaces | Sync Window |
|----------|-----------|-------------|
| `dev` | `dev`, `dev-*` | 24/7 |
| `staging` | `staging`, `staging-*` | 24/7 |
| `prod` | `prod`, `prod-*` | Solo 2-6 AM UTC |
| `preview` | `preview-*` | 24/7 |

## Preview Environments (Ambientes Efímeros)

### Configuración en este repo

| Archivo | Función |
|---------|---------|
| `argocd/projects/preview-project.yaml` | Project con namespaces `preview-*` |
| `argocd/applications/preview/applicationset-preview.yaml` | ApplicationSet con PR Generator |
| `values/preview/values.yaml` | Values base (recursos reducidos, imagen placeholder) |

### Cómo funciona

El ApplicationSet usa un **Pull Request Generator** que monitorea PRs con label `preview` en el repo de la app (`bcocbo/test-app123`).

La imagen se resuelve por **convención de tag** sin modificar este repo:

```
CI (repo de la app)                    ApplicationSet (este repo)
───────────────────                    ────────────────────────────
Tag: pr-{number}-{short_sha}           Parameter: pr-{{number}}-{{head_short_sha}}
     pr-42-a1b2c3d                              pr-42-a1b2c3d
```

Los `parameters` del ApplicationSet sobreescriben los values base:
- `microservice.image` — imagen de ECR con tag del PR
- `microservice.name` — nombre único por PR
- `microservice.namespace` — namespace efímero

### Ciclo de vida

1. **Creación**: PR abierto con label `preview` → ArgoCD crea Application + namespace
2. **Actualización**: Nuevo push al PR → CI genera nueva imagen → ArgoCD sincroniza
3. **Destrucción**: PR cerrado/mergeado → ApplicationSet elimina todo automáticamente

## Agregar una nueva aplicación

1. Crear el values file:
   ```bash
   mkdir -p values/dev/{app-name}
   # Copiar y adaptar de una app existente
   cp values/dev/tes-app-123/values.yaml values/dev/{app-name}/values.yaml
   ```

2. Crear la Application:
   ```bash
   # Copiar y adaptar
   cp argocd/applications/dev/tes-app-123.yaml argocd/applications/dev/{app-name}.yaml
   ```

3. Commit y push — el app-of-apps lo detecta automáticamente.

## Flujo CI/CD completo

```
Repo de la App                    Este Repo (gitops-apps)              ArgoCD
──────────────                    ───────────────────────              ──────

Push a main
    │
    ▼
CI: build + push ECR
    │
    ▼
CI: crea PR en gitops-apps ──────► PR actualiza values.yaml
                                        │
                                        ▼ (merge)
                                   main actualizado ──────────────► Sync automático
                                                                        │
                                                                        ▼
                                                                   Deploy a K8s


PR con label "preview"
    │
    ▼
CI: build + push ECR
(tag: pr-{n}-{sha})
                                   ApplicationSet detecta PR ─────► Crea Application
                                   (PR Generator)                       │
                                        │                               ▼
                                        └── Parameters construyen ► Deploy a
                                            la imagen por convención   preview-{branch}-{n}
```

---
Repositorio gestionado con ArgoCD App-of-Apps pattern.
