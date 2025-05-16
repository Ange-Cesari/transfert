# GitLab Broadcast Automation Script

Ce script Bash permet de diffuser des messages de broadcast sur plusieurs instances GitLab de manière centralisée et automatisée.

## 📦 Contenu

- `broadcast.sh` : Script Bash principal.
- `config.yaml` : Fichier de configuration des tenants et workspaces.

---

## ⚙️ Configuration

### Variables Modifiables dans le Script (`broadcast.sh`)

\`\`\`bash
CONFIG_FILE="config.yaml"    # Chemin du fichier de configuration des tenants
DOMAIN="domain.local"        # Domaine utilisé pour construire les URLs GitLab
MESSAGE=""                   # Message du broadcast (si vide, doit être défini via CLI)
START_DATE=""                # Date de début (format ISO 8601)
END_DATE=""                  # Date de fin (format ISO 8601)
DISMISSIBLE="true"           # true/false pour rendre la bannière dismissible

# Scope par défaut (utilisé si aucun argument CLI n'est passé)
SCOPE="--all"
# Exemples :
# SCOPE="--all"
# SCOPE="--tenant toto"
# SCOPE="--tenants toto:t1,t2 titi:ti1"
\`\`\`

---

### Fichier `config.yaml`

Ce fichier définit les tenants, workspaces et les tokens d'authentification GitLab.

\`\`\`yaml
tenants:
  toto:
    t1: "TOKEN_T1"
    t2: "TOKEN_T2"
  titi:
    ti1: "TOKEN_TI1"
  tutu:
    tu1: "TOKEN_TU1"
    tu2: "TOKEN_TU2"
\`\`\`

- **tenants** : Groupe logique de workspaces.
- **workspaces** : Correspondent à des instances GitLab accessibles via \`https://gitlab.<workspacetenant>.<tenant>.<DOMAIN>\`.

---

## 🚀 Utilisation

### Exécution Simple avec Scope Défini dans le Script

\`\`\`bash
./broadcast.sh
\`\`\`

### Utilisation avec Arguments CLI (Priorité sur les variables du script)

\`\`\`bash
./broadcast.sh --all --message "Maintenance tonight!" --start "2025-05-14T22:00:00Z" --end "2025-05-15T02:00:00Z" --dismissible true
\`\`\`

#### Options CLI Disponibles

| Option         | Description                                    |
|----------------|------------------------------------------------|
| \`--all\`        | Envoie le message à toutes les tenants/workspaces |
| \`--tenant <tenant>\`| Cible une tenant spécifique                      |
| \`--tenants <tenant1:workspace1,workspace2 ...>\` | Cible des workspaces spécifiques |
| \`--message\`    | Contenu du message                             |
| \`--start\`      | Date de début (ISO 8601)                       |
| \`--end\`        | Date de fin (ISO 8601)                         |
| \`--dismissible true|false\` | Rend la bannière dismissible ou non |
| \`--domain\`     | Surcharge la variable DOMAIN                  |

---

### Exemples

1. **Envoi à toutes les instances définies dans `config.yaml` :**
\`\`\`bash
./broadcast.sh --all --message "System maintenance tonight!"
\`\`\`

2. **Envoi à une tenant spécifique :**
\`\`\`bash
./broadcast.sh --tenant toto --message "Toto tenant maintenance."
\`\`\`

3. **Envoi à des workspaces précises :**
\`\`\`bash
./broadcast.sh --tenants "toto:t1,t2" "titi:ti1" --message "Partial downtime expected."
\`\`\`

---

## 📚 Notes Importantes

- Si une variable est définie à la fois dans le script et via CLI, **la valeur CLI est prioritaire**.
- Si aucune valeur n’est définie pour \`MESSAGE\`, le script refusera de s’exécuter.
- Une pré-vérification est effectuée avant l’envoi des messages :  
  - Si une tenant ou une workspace n'existe pas dans \`config.yaml\`, le script s'arrête immédiatement avec un message d'erreur.

---

## ✅ Prérequis

- \`yq\` pour parser le fichier YAML.  
  - Installation :  
    - Debian/Ubuntu : \`sudo apt install yq\`  
    - MacOS : \`brew install yq\`
- \`jq\` pour formater les données JSON.
- \`curl\` pour les requêtes HTTP.

---

## 📅 Formats de Date

Les dates doivent être au format **ISO 8601** :

\`\`\`
YYYY-MM-DDTHH:MM:SSZ
\`\`\`

Exemple :  
\`\`\`bash
START_DATE="2025-05-14T22:00:00Z"
END_DATE="2025-05-15T02:00:00Z"
\`\`\`

---

## 📝 Licence

Script interne à usage personnel ou entreprise. À adapter selon vos besoins.  
Aucune garantie de support.