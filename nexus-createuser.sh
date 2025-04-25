#!/bin/bash

# Configuration
NEXUS_URL="http://localhost:8081"  # URL de votre instance Nexus
NEXUS_ADMIN_USER="admin"           # Nom d'utilisateur administrateur
NEXUS_ADMIN_PASS="admin123"        # Mot de passe administrateur

PREFIX_ENABLED=true                # Activer ou non le préfixe
PREFIX="sa"                        # Préfixe à utiliser
SEPARATOR="-"                      # Séparateur entre le préfixe et le userId
EMAIL_DOMAIN="fake.com"            # Domaine de l'email
PASSWORD_LENGTH=16                 # Longueur du mot de passe

# Liste des rôles à assigner à l'utilisateur
ROLES=("nx-admin" "nx-developer")  # Modifiez cette liste selon vos besoins

# Fonction pour générer un mot de passe aléatoire
generate_password() {
    local length=$1
    local chars='A-Za-z0-9(|{}!:;,?./@&)'
    tr -dc "$chars" < /dev/urandom | head -c "$length"
}

# Demande du userId
read -rp "Entrez le userId du compte à créer : " USERID

# Construction du firstName et lastName
if [ "$PREFIX_ENABLED" = true ]; then
    FIRST_NAME="$PREFIX"
    LAST_NAME="$USERID"
    USERNAME="${PREFIX}${SEPARATOR}${USERID}"
else
    FIRST_NAME="$USERID"
    LAST_NAME="$USERID"
    USERNAME="$USERID"
fi

# Construction de l'email
EMAIL="${USERNAME}@${EMAIL_DOMAIN}"

# Génération du mot de passe
PASSWORD=$(generate_password "$PASSWORD_LENGTH")

# Construction du payload JSON
ROLES_JSON=$(printf '"%s",' "${ROLES[@]}")
ROLES_JSON="[${ROLES_JSON%,}]"

read -r -d '' PAYLOAD <<EOF
{
  "userId": "$USERNAME",
  "firstName": "$FIRST_NAME",
  "lastName": "$LAST_NAME",
  "emailAddress": "$EMAIL",
  "password": "$PASSWORD",
  "status": "active",
  "roles": $ROLES_JSON
}
EOF

# Affichage du payload pour vérification
echo "Payload JSON généré :"
echo "$PAYLOAD"

# Envoi de la requête à l'API REST de Nexus
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
  -u "$NEXUS_ADMIN_USER:$NEXUS_ADMIN_PASS" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$NEXUS_URL/service/rest/v1/security/users")

# Vérification de la réponse
if [ "$RESPONSE" -eq 204 ]; then
    echo "Utilisateur '$USERNAME' créé avec succès."
    echo "Mot de passe : $PASSWORD"
else
    echo "Échec de la création de l'utilisateur. Code HTTP : $RESPONSE"
fi