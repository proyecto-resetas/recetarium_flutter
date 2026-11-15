# Imagen de producción de la PWA Recetarium (Flutter Web servido con Nginx).
#
# El build web se genera ANTES en tu máquina:
#   flutter build web --release
# y aquí solo se copia `build/web/` a Nginx.
FROM nginx:1.27-alpine

# Configuración de Nginx (puerto 8000, fallback SPA y cabeceras de caché)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Archivos estáticos de la PWA
COPY build/web /usr/share/nginx/html

# Koyeb envía el tráfico al puerto 8000 por defecto
EXPOSE 8000

CMD ["nginx", "-g", "daemon off;"]
