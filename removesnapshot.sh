#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <directory> [--dry-run]"
  exit 1
fi

TARGET_DIR="$1"
DRY_RUN=false
LOG_FILE="snapshot_rename.log"
> "$LOG_FILE"

if [ "$2" == "--dry-run" ]; then
  DRY_RUN=true
  echo "[MODE] Dry-run activé. Aucun fichier ne sera modifié." | tee -a "$LOG_FILE"
fi

# Parcours récursif des fichiers
find "$TARGET_DIR" -type f | while read -r file; do
  dir=$(dirname "$file")
  base=$(basename "$file")

  original_path="$file"
  new_base="$base"

  # Étape 1 : remplacer X.Y.Z.123456.789012 par X.Y.Z-SNAPSHOT
  new_base=$(echo "$new_base" | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)[.-][0-9]+\.[0-9]+/\1-SNAPSHOT/')

  # Étape 2 : nettoyer SNAPSHOT-123456.789012 → SNAPSHOT
  new_base=$(echo "$new_base" | sed -E 's/SNAPSHOT-[0-9]+\.[0-9]+/SNAPSHOT/')

  # Chemin complet après transformation
  new_path="$dir/$new_base"

  if [ "$original_path" != "$new_path" ]; then
    if $DRY_RUN; then
      echo "[Dry-run] $original_path -> $new_path" | tee -a "$LOG_FILE"
    else
      mv "$original_path" "$new_path"
      echo "Renommé : $original_path -> $new_path" | tee -a "$LOG_FILE"
    fi
  fi
done

echo "=== Fin du traitement ===" | tee -a "$LOG_FILE"