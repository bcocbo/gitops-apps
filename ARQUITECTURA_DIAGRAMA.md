# Diagrama de Arquitectura - Backstage GitOps Platform

## Arquitectura Completa

```mermaid
graph LR
    %% Usuarios
    DEV[👤 Developer]
    OPS[👤 Platform Team]
    
    %% Backstage
    subgraph Backstage["🏢 Backstage Platform"]
        BS[Backstage<br/>Developer Portal]
        PG[(PostgreSQL<br/>Catalog DB)]
        BS --> PG
    end
    
    %% GitHub
    subgraph GitHub["📦 GitHub"]
        subgraph AppRepos["Application Repos"]
            APP1[my-app]
            APP2[other-app]
        end
        GITOPS[gitops-apps<br/>Centralized]
        HELM[eks_baseline<br/>_chart_Helm]
        GHA[GitHub Actions<br/>CI/CD]
    end
    
    %% AWS
    subgraph AWS["☁️ AWS"]
        ECR[Amazon ECR<br/>Container Registry]
    end
    
    %% ArgoCD
    ARGO[🔄 ArgoCD<br/>GitOps Engine]
    
    %% Kubernetes
    subgraph K8S["☸️ Kubernetes Clusters"]
        subgraph DEV_ENV["Dev Environment"]
            DEV_NS[dev namespace]
            DEV_POD[app pods]
            DEV_NS --> DEV_POD
        end
        subgraph STG_ENV["Staging Environment"]
            STG_NS[staging namespace]
            STG_POD[app pods]
            STG_NS --> STG_POD
        end
        subgraph PROD_ENV["Production Environment"]
            PROD_NS[prod namespace]
            PROD_POD[app pods]
            PROD_NS --> PROD_POD
        end
    end
    
    %% Flujo principal
    DEV -->|1. Create App| BS
    BS -->|2. Generate Code| APP1
    BS -->|3. Create PR| GITOPS
    
    OPS -->|4. Approve PR| GITOPS
    
    DEV -->|5. Push Code| APP1
    APP1 -->|6. Trigger CI| GHA
    GHA -->|7. Build & Push| ECR
    GHA -->|8. Update Values| GITOPS
    
    ARGO -->|9. Watch| GITOPS
    ARGO -->|10. Read Chart| HELM
    ARGO -->|11. Pull Image| ECR
    ARGO -->|12. Deploy| DEV_NS
    ARGO -->|12. Deploy| STG_NS
    ARGO -->|12. Deploy| PROD_NS
    
    BS -.->|13. Monitor Status| ARGO
    OPS -.->|14. View Status| BS
    DEV -.->|15. Check Deployment| BS
    
    style BS fill:#4A90E2
    style ARGO fill:#FF6B35
    style ECR fill:#FF9900
    style GITOPS fill:#28A745
    style HELM fill:#0F1689
```

## Flujo Detallado de Creación de Aplicación

```mermaid
sequenceDiagram
    participant Dev as 👤 Developer
    participant BS as Backstage
    participant GH as GitHub
    participant GitOps as GitOps Repo
    participant Ops as 👤 Platform Team
    participant Argo as ArgoCD
    participant K8s as Kubernetes
    
    Dev->>BS: 1. Accede a "Create"
    Dev->>BS: 2. Selecciona template ArgoCD
    Dev->>BS: 3. Completa formulario
    Note over Dev,BS: Nombre, tipo, lenguaje,<br/>entorno, réplicas
    
    BS->>GH: 4. Crea repositorio de app
    Note over BS,GH: Incluye código, Dockerfile,<br/>CI/CD workflow
    
    BS->>GitOps: 5. Crea PR con configuración
    Note over BS,GitOps: values.yaml<br/>argocd-application.yaml
    
    BS->>BS: 6. Registra en catálogo
    BS-->>Dev: 7. Muestra links (repo, PR, catalog)
    
    Ops->>GitOps: 8. Revisa PR
    Ops->>GitOps: 9. Aprueba y merge
    
    Argo->>GitOps: 10. Detecta cambios (polling)
    Argo->>K8s: 11. Despliega aplicación
    K8s-->>Argo: 12. Confirma despliegue
    
    Dev->>BS: 13. Verifica en catálogo
    BS->>Argo: 14. Consulta estado
    Argo-->>BS: 15. Retorna sync status
    BS-->>Dev: 16. Muestra estado en UI
```

## Flujo de CI/CD y Actualización

```mermaid
sequenceDiagram
    participant Dev as 👤 Developer
    participant AppRepo as App Repository
    participant GHA as GitHub Actions
    participant ECR as Amazon ECR
    participant GitOps as GitOps Repo
    participant Ops as 👤 Platform Team
    participant Argo as ArgoCD
    participant K8s as Kubernetes
    
    Dev->>AppRepo: 1. Push código
    AppRepo->>GHA: 2. Trigger workflow
    
    GHA->>GHA: 3. Run tests
    GHA->>GHA: 4. Build Docker image
    Note over GHA: Tag: branch-sha-run
    
    GHA->>ECR: 5. Push image
    ECR-->>GHA: 6. Confirm push
    
    GHA->>GitOps: 7. Clone repo
    GHA->>GitOps: 8. Update values.yaml
    Note over GHA,GitOps: Actualiza image.tag
    
    GHA->>GitOps: 9. Create PR
    Note over GHA,GitOps: PR con nuevo tag de imagen
    
    Ops->>GitOps: 10. Review PR
    Ops->>GitOps: 11. Approve & Merge
    
    Argo->>GitOps: 12. Detect changes
    Argo->>ECR: 13. Pull new image
    Argo->>K8s: 14. Update deployment
    
    K8s->>K8s: 15. Rolling update
    K8s-->>Argo: 16. Sync complete
    
    Dev->>AppRepo: 17. Check status in Backstage
    Note over Dev,K8s: ArgoCD card muestra<br/>sync status y health
```

## Componentes y Responsabilidades

```mermaid
graph TB
    subgraph "Developer Portal"
        BS[Backstage]
        CAT[Software Catalog]
        TEMP[Templates]
        DOCS[TechDocs]
        BS --> CAT
        BS --> TEMP
        BS --> DOCS
    end
    
    subgraph "Source Control"
        APP[App Repositories]
        GITOPS[GitOps Repository]
        HELM[Helm Chart Repo]
    end
    
    subgraph "CI/CD"
        GHA[GitHub Actions]
        TEST[Tests]
        BUILD[Docker Build]
        SCAN[Security Scan]
        GHA --> TEST
        GHA --> BUILD
        GHA --> SCAN
    end
    
    subgraph "Container Registry"
        ECR[Amazon ECR]
        TAGS[Image Tags]
        SCAN2[Vulnerability Scan]
        ECR --> TAGS
        ECR --> SCAN2
    end
    
    subgraph "GitOps Engine"
        ARGO[ArgoCD]
        SYNC[Sync Controller]
        HEALTH[Health Check]
        ARGO --> SYNC
        ARGO --> HEALTH
    end
    
    subgraph "Kubernetes"
        NS[Namespaces]
        PODS[Pods]
        SVC[Services]
        ING[Ingress]
        NS --> PODS
        NS --> SVC
        NS --> ING
    end
    
    BS --> APP
    APP --> GHA
    GHA --> ECR
    GHA --> GITOPS
    ARGO --> GITOPS
    ARGO --> HELM
    ARGO --> ECR
    ARGO --> NS
    BS -.-> ARGO
    
    style BS fill:#4A90E2
    style ARGO fill:#FF6B35
    style ECR fill:#FF9900
    style GITOPS fill:#28A745
```

## Arquitectura de Seguridad

```mermaid
graph TB
    subgraph "Authentication & Authorization"
        AUTH[Backstage Auth]
        RBAC[ArgoCD RBAC]
        OIDC[AWS OIDC]
    end
    
    subgraph "Secrets Management"
        ENV[.env file<br/>local only]
        K8S_SEC[Kubernetes Secrets]
        GH_SEC[GitHub Secrets]
    end
    
    subgraph "Network Security"
        TLS[TLS/HTTPS]
        NETPOL[Network Policies]
        ING_AUTH[Ingress Auth]
    end
    
    subgraph "Container Security"
        NONROOT[Non-root User]
        SECCTX[Security Context]
        READONLY[Read-only FS]
        SCAN[Image Scanning]
    end
    
    AUTH --> RBAC
    RBAC --> OIDC
    ENV --> K8S_SEC
    K8S_SEC --> GH_SEC
    TLS --> NETPOL
    NETPOL --> ING_AUTH
    NONROOT --> SECCTX
    SECCTX --> READONLY
    READONLY --> SCAN
    
    style AUTH fill:#E74C3C
    style K8S_SEC fill:#E74C3C
    style TLS fill:#E74C3C
    style NONROOT fill:#E74C3C
```

## Estructura de Repositorios

```
📦 Repositorios
│
├── 🏢 backstage-app-poc-main (este repo)
│   ├── examples/argocd-template/     # Template de Backstage
│   ├── packages/app/                 # Frontend
│   ├── packages/backend/             # Backend
│   └── charts/eks_baseline_chart_Helm/  # Chart local
│
├── 📦 eks_baseline_chart_Helm (GitHub)
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── templates/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   └── ...
│   └── README.md
│
├── 🔄 gitops-apps (GitHub)
│   ├── values/
│   │   ├── dev/
│   │   │   └── my-app/
│   │   │       └── values.yaml
│   │   ├── staging/
│   │   └── prod/
│   ├── argocd/
│   │   ├── projects/
│   │   │   ├── dev-project.yaml
│   │   │   ├── staging-project.yaml
│   │   │   └── prod-project.yaml
│   │   ├── applications/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── prod/
│   │   └── app-of-apps.yaml
│   └── charts/
│
└── 📱 my-app (GitHub - generado por template)
    ├── src/                          # Código fuente
    ├── Dockerfile                    # Multi-stage build
    ├── .github/workflows/ci.yaml     # CI/CD pipeline
    ├── catalog-info.yaml             # Metadata de Backstage
    └── README.md
```

## Flujo de Datos

```
┌─────────────┐
│  Developer  │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│                    Backstage                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │ Catalog  │  │Templates │  │ TechDocs │             │
│  └──────────┘  └──────────┘  └──────────┘             │
└──────┬──────────────────────────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────────────────────────┐
│                      GitHub                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │  App Repos   │  │ GitOps Repo  │  │  Helm Chart  │ │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘ │
└─────────┼──────────────────┼──────────────────────────┘
          │                  │
          ▼                  │
    ┌──────────┐            │
    │ CI/CD    │            │
    │ Pipeline │            │
    └────┬─────┘            │
         │                  │
         ▼                  │
    ┌──────────┐            │
    │ ECR      │            │
    │ Registry │            │
    └────┬─────┘            │
         │                  │
         └──────────┬───────┘
                    │
                    ▼
              ┌──────────┐
              │ ArgoCD   │
              └────┬─────┘
                   │
                   ▼
         ┌──────────────────┐
         │   Kubernetes      │
         │  ┌────┐ ┌────┐   │
         │  │Dev │ │Prod│   │
         │  └────┘ └────┘   │
         └──────────────────┘
```

## Tecnologías Utilizadas

| Componente | Tecnología | Propósito |
|------------|-----------|-----------|
| **Developer Portal** | Backstage | Catálogo de servicios, templates |
| **Source Control** | GitHub | Repositorios de código |
| **CI/CD** | GitHub Actions | Automatización de builds |
| **Container Registry** | Amazon ECR | Almacenamiento de imágenes |
| **GitOps Engine** | ArgoCD | Continuous Deployment |
| **Orchestration** | Kubernetes (EKS) | Ejecución de contenedores |
| **Package Manager** | Helm | Gestión de configuración |
| **Database** | PostgreSQL | Catálogo de Backstage |
| **Authentication** | AWS OIDC | Autenticación sin keys |

## Ventajas de esta Arquitectura

### 🎯 Escalabilidad
- Soporta 100+ aplicaciones
- Múltiples equipos independientes
- Crecimiento horizontal

### 🔐 Seguridad
- Separación de responsabilidades
- Auditoría completa
- Secrets management
- RBAC en todos los niveles

### 🚀 Velocidad
- Despliegues automatizados
- CI/CD integrado
- Rollbacks rápidos

### 👁️ Visibilidad
- Vista centralizada
- Estado en tiempo real
- Historial completo

### 📊 Governance
- Aprobaciones requeridas
- Políticas por entorno
- Compliance automático

---

**Nota**: Este diagrama representa la arquitectura implementada en este proyecto.
Para visualizar los diagramas Mermaid, abre este archivo en GitHub o en un editor que soporte Mermaid.
