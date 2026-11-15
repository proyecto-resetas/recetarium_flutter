#!/usr/bin/env bash
# Compila la PWA, construye la imagen Docker (linux/amd64 para Koyeb)
# y la sube a Docker Hub.
#
# Uso:
#   ./deploy_web.sh <usuario_dockerhub> [tag]
# Ejemplo:
#   ./deploy_web.sh danieljimenez v1.0.0
set -euo pipefail

DOCKER_USER="${1:?Indica tu usuario de Docker Hub: ./deploy_web.sh <usuario> [tag]}"
TAG="${2:-latest}"
IMAGE="docker.io/${DOCKER_USER}/recetarium-web"

echo "▶ Compilando Flutter Web..."
flutter build web --release --no-wasm-dry-run

echo "▶ Construyendo y subiendo ${IMAGE}:${TAG} (linux/amd64)..."
docker buildx build \
  --platform linux/amd64 \
  -t "${IMAGE}:${TAG}" \
  -t "${IMAGE}:latest" \
  --push \
  .

echo "✅ Imagen publicada: ${IMAGE}:${TAG}"
echo "   En Koyeb usa: ${IMAGE}:${TAG}  (puerto 8000)"
