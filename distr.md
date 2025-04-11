
# Documentation : Exécution croisée entre *host*, *distrobox* et `flatpak`

## Pré-requis

- Fedora Silverblue (ou OS immuable équivalent)
- `distrobox` installé et fonctionnel
- `flatpak` installé côté *host*
- Une distrobox (ex: nommée `devbox`) configurée avec accès au binaire `flatpak` (optionnel)

---

## 1. Exécuter une commande sur le host depuis la distrobox

Depuis une distrobox, tu peux accéder au système hôte avec la commande spéciale `distrobox-host-exec`.

### Exemple :

```bash
distrobox-host-exec echo "Hello depuis le host"
```

### Remarques :
- `distrobox-host-exec` permet d'exécuter **n'importe quelle commande** présente sur le host.
- Il est disponible dans toutes les distrobox créées avec `distrobox`.

---

## 2. Exécuter un `flatpak run` sur le host

Tu peux utiliser `flatpak run` directement via `distrobox-host-exec` :

### Exemple :

```bash
distrobox-host-exec flatpak run com.discordapp.Discord
```

Cela va lancer l'application Flatpak **comme si tu étais sur le host**, mais déclenchée depuis la distrobox.

---

## 3. Appeler `flatpak` depuis la distrobox (en l’agrégeant au host)

### Option 1 : Utiliser toujours `distrobox-host-exec flatpak run ...`

C’est le plus simple. Tu peux même créer un alias dans la distrobox :

```bash
alias flatpak='distrobox-host-exec flatpak'
```

Ainsi, toutes les commandes `flatpak` de ta session distrobox appelleront celles du host.

### Option 2 : Monter le binaire `flatpak` du host dans la distrobox

Lors de la création de la distrobox, tu peux monter le binaire et les sockets nécessaires :

```bash
distrobox-create --name devbox --image docker.io/library/fedora:latest \
  --mount "$XDG_RUNTIME_DIR/flatpak:$XDG_RUNTIME_DIR/flatpak" \
  --additional-packages flatpak \
  --init-hooks "ln -sf /run/host/usr/bin/flatpak /usr/local/bin/flatpak"
```

Mais cette méthode est plus fragile et dépend de la structure du host.

### Option 3 : Script wrapper

Crée un petit script dans ta distrobox :

```bash
mkdir -p ~/.local/bin
cat > ~/.local/bin/flatpak-host << 'EOF'
#!/bin/bash
distrobox-host-exec flatpak "$@"
EOF

chmod +x ~/.local/bin/flatpak-host
```

Et tu peux ensuite appeler `flatpak-host run ...` depuis la distrobox.

---

## Bonus : Flatpak GUI via Distrobox (ex: lancer une app graphique)

```bash
distrobox-host-exec flatpak run org.gnome.Calculator
```

Même avec Wayland ou X11, ça marche car la session graphique est déjà partagée avec la distrobox.

---

## En résumé

| Action                              | Commande                                                                 |
|-------------------------------------|--------------------------------------------------------------------------|
| Exécuter une commande host          | `distrobox-host-exec <commande>`                                         |
| Lancer un flatpak host depuis box   | `distrobox-host-exec flatpak run <app>`                                  |
| Alias flatpak dans distrobox        | `alias flatpak='distrobox-host-exec flatpak'`                            |
| Script wrapper                      | Crée `flatpak-host` pointant vers `distrobox-host-exec flatpak "$@"`     |

---