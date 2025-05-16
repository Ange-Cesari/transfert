# GitLab Broadcast Automation Script

Ce script Bash permet de diffuser des messages de broadcast sur plusieurs instances GitLab de manière centralisée et automatisée.

## 📦 Contenu

- `broadcast.sh` : Script Bash principal.
- `config.yaml` : Fichier de configuration des zones et sous-zones.

---

## ⚙️ Configuration

### Variables Modifiables dans le Script (`broadcast.sh`)

\`\`\`bash
CONFIG_FILE="config.yaml"    # Chemin du fichier de configuration des zones
DOMAIN="domain.local"        # Domaine utilisé pour construire les URLs GitLab
MESSAGE=""                   # Message du broadcast (si vide, doit être défini via CLI)
START_DATE=""                # Date de début (format ISO 8601)
END_DATE=""                  # Date de fin (format ISO 8601)
DISMISSIBLE="true"           # true/false pour rendre la bannière dismissible

# Scope par défaut (utilisé si aucun argument CLI n'est passé)
SCOPE="--all"
# Exemples :
# SCOPE="--all"
# SCOPE="--zone toto"
# SCOPE="--zones toto:t1,t2 titi:ti1"
\`\`\`

---

### Fichier `config.yaml`

Ce fichier définit les zones, sous-zones et les tokens d'authentification GitLab.

\`\`\`yaml
zones:
  toto:
    t1: "TOKEN_T1"
    t2: "TOKEN_T2"
  titi:
    ti1: "TOKEN_TI1"
  tutu:
    tu1: "TOKEN_TU1"
    tu2: "TOKEN_TU2"
\`\`\`

- **zones** : Groupe logique de sous-zones.
- **sous-zones** : Correspondent à des instances GitLab accessibles via \`https://gitlab.<subzone>.<zone>.<DOMAIN>\`.

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
| \`--all\`        | Envoie le message à toutes les zones/sous-zones |
| \`--zone <zone>\`| Cible une zone spécifique                      |
| \`--zones <zone1:sub1,sub2 ...>\` | Cible des sous-zones spécifiques |
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

2. **Envoi à une zone spécifique :**
\`\`\`bash
./broadcast.sh --zone toto --message "Toto zone maintenance."
\`\`\`

3. **Envoi à des sous-zones précises :**
\`\`\`bash
./broadcast.sh --zones "toto:t1,t2" "titi:ti1" --message "Partial downtime expected."
\`\`\`

---

## 📚 Notes Importantes

- Si une variable est définie à la fois dans le script et via CLI, **la valeur CLI est prioritaire**.
- Si aucune valeur n’est définie pour \`MESSAGE\`, le script refusera de s’exécuter.
- Une pré-vérification est effectuée avant l’envoi des messages :  
  - Si une zone ou une sous-zone n'existe pas dans \`config.yaml\`, le script s'arrête immédiatement avec un message d'erreur.

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