
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar package files
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Production stage
FROM node:20-alpine

WORKDIR /app

# Copiar dependencias y código desde builder
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app .

# Usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

USER nodejs

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js || exit 1

# Comando de inicio
CMD ["node", "index.js"]



# Metadata común
LABEL app.name="test-app03"
LABEL app.environment="dev"
LABEL app.type="custom"

LABEL app.language="nodejs"

