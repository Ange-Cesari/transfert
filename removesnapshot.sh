
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

  # Ne rien faire si le nom est déjà propre
  if [[ "$base" =~ SNAPSHOT$ ]] || [[ "$base" =~ SNAPSHOT\. ]]; then
    continue
  fi

  # Si contient SNAPSHOT suivi d’un build number, on le supprime
  if [[ "$base" =~ SNAPSHOT-[0-9]+\.[0-9]+ ]]; then
    new_base=$(echo "$base" | sed -E 's/SNAPSHOT-[0-9]+\.[0-9]+/SNAPSHOT/')
    new_path="$dir/$new_base"
    if [ "$file" != "$new_path" ]; then
      mv "$file" "$new_path"
      echo "Renamed (cleanup after SNAPSHOT): $file -> $new_path" | tee -a "$LOG_FILE"
    fi
    continue
  fi

  # Sinon, remplacer un build number standalone (non version) par SNAPSHOT
  if [[ "$base" =~ -[0-9]+\.[0-9]+ ]]; then
    # Attention à ne pas casser une vraie version comme 1.2.0
    # On ignore les cas où le motif est juste après une version du type 1.2.0
    if ! [[ "$base" =~ [0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+ ]]; then
      continue
    fi
    new_base=$(echo "$base" | sed -E 's/-[0-9]+\.[0-9]+/ -SNAPSHOT/' | sed 's/ //')
    new_path="$dir/$new_base"
    if [ "$file" != "$new_path" ]; then
      mv "$file" "$new_path"
      echo "Renamed (build -> SNAPSHOT): $file -> $new_path" | tee -a "$LOG_FILE"
    fi
  fi
done

echo "Renaming completed. Log saved in $LOG_FILE"

