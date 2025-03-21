
#!/bin/bash

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <path_to_directory>"
  exit 1
fi

TARGET_DIR="$1"
LOG_FILE="snapshot_rename.log"
> "$LOG_FILE"

find "$TARGET_DIR" -type f | while read -r file; do
  dir=$(dirname "$file")
  base=$(basename "$file")

  # Cas 1 : contient une vraie version + bloc de build
  # Exemple : truc-1.2.0.123456.789012-abc.pom
  if [[ "$base" =~ ([0-9]+\.[0-9]+\.[0-9]+)\.([0-9]+\.[0-9]+) ]]; then
    version="${BASH_REMATCH[1]}"
    suffix="${BASH_REMATCH[2]}"
    # remplace .123456.789012 par -SNAPSHOT
    new_base=$(echo "$base" | sed -E "s/(${version})\.${suffix}/\1-SNAPSHOT/")
    new_path="$dir/$new_base"
    if [ "$file" != "$new_path" ]; then
      mv "$file" "$new_path"
      echo "Renamed (version+build -> SNAPSHOT): $file -> $new_path" | tee -a "$LOG_FILE"
    fi
    continue
  fi

  # Cas 2 : fichier a déjà -SNAPSHOT suivi d’un build (on le nettoie)
  if [[ "$base" =~ SNAPSHOT-[0-9]+\.[0-9]+ ]]; then
    new_base=$(echo "$base" | sed -E 's/SNAPSHOT-[0-9]+\.[0-9]+/SNAPSHOT/')
    new_path="$dir/$new_base"
    if [ "$file" != "$new_path" ]; then
      mv "$file" "$new_path"
      echo "Renamed (cleanup SNAPSHOT-build): $file -> $new_path" | tee -a "$LOG_FILE"
    fi
    continue
  fi
done

echo "Renaming completed. Log saved in $LOG_FILE"