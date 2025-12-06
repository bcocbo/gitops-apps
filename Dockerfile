FROM nginxdemos/hello:latest

# Aplicación Hola Mundo
# Esta imagen ya contiene una aplicación de demostración

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
