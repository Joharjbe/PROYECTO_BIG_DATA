#!/bin/bash
set -e

echo "Creando carpetas en HDFS..."
docker exec namenode hdfs dfs -mkdir -p /datalake/bronze/yelp

# Verificar si /datalake/silver existe; si no, crear y ajustar permisos
if ! docker exec namenode hdfs dfs -test -d /datalake/silver; then
  echo "Configurando permisos de /datalake para el usuario jovyan..."
  docker exec namenode hdfs dfs -mkdir -p /datalake/silver
  docker exec -u 0 namenode hdfs dfs -chown -R jovyan /datalake
fi

echo "📂 Verificando existencia de archivos..."
if ! docker exec namenode test -f /data/bronze/yelp/yelp_academic_dataset_review.json; then
  echo "No se encuentran los archivos JSON en /data/bronze/yelp dentro del contenedor."
  echo "Asegúrate de montar correctamente la carpeta ./data en docker-compose:"
  echo "    volumes:"
  echo "      - ./data:/data"
  exit 1
fi

echo "⬆Subiendo archivos JSON a HDFS..."
docker exec namenode bash -c 'hdfs dfs -put -f /data/bronze/yelp/*.json /datalake/bronze/yelp'

echo "¡Carga completa! Archivos JSON disponibles en HDFS en /datalake/bronze/yelp"
