
# Usando imagen preconstruida
FROM nginxdemos/hello:latest

# Metadata
LABEL maintainer="platform@example.com"
LABEL app="test-app02"
LABEL environment="dev"

# Exponer puerto (ajustar según la imagen)
EXPOSE 80



# Metadata común
LABEL app.name="test-app02"
LABEL app.environment="dev"
LABEL app.type="prebuilt"

