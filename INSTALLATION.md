# Guide d'Installation - Client Radar OS

Suivez ces étapes simples pour configurer votre propre instance privée de **Client Radar OS**.

---

## Étape 1 : Créer le Dépôt GitHub Privé
1. Rendez-vous sur votre compte GitHub.
2. Créez un nouveau dépôt appelé obligatoirement : `client-radar-os-private`.
3. Cochez impérativement la case **Private** (Dépôt Privé).
4. Clonez-le sur votre machine de travail et copiez tous les fichiers du projet Client Radar OS dedans.

---

## Étape 2 : Configurer les Secrets GitHub (Secrets Actions)
Pour exécuter les recherches automatiques de prospects, GitHub Actions a besoin de clés d'API configurées en Secrets de dépôt.
1. Allez sur votre dépôt GitHub privé, puis dans **Settings** > **Secrets and variables** > **Actions** > **New repository secret**.
2. Ajoutez les secrets suivants :
   *   `GOOGLE_API_KEY` : Votre clé d'accès Google Cloud Console (nécessaire pour la recherche Google).
   *   `GOOGLE_CSE_ID` : Votre identifiant unique Google Custom Search Engine configuré pour indexer le web.
   *   `FREELANCER_TOKEN` (Optionnel) : Votre jeton de connexion API pour Freelancer.com.
   *   `REDDIT_CLIENT_ID` / `REDDIT_CLIENT_SECRET` (Optionnels) : Vos identifiants développeur Reddit.

---

## Étape 3 : Activer GitHub Actions
1. Dans votre dépôt GitHub, cliquez sur l'onglet **Actions**.
2. Si GitHub affiche un avertissement concernant les workflows des dépôts clonés, cliquez sur **I understand my workflows, go ahead and enable them**.
3. Vous devriez voir le workflow **Client Radar OS** apparaître dans la barre latérale gauche.

---

## Étape 4 : Activer GitHub Pages
Pour rendre vos pages d'offres commerciales accessibles en ligne à vos clients :
1. Allez dans **Settings** (Paramètres du Dépôt) > **Pages** (Barre latérale gauche).
2. Dans la section **Build and deployment** :
   *   Source : Sélectionnez **GitHub Actions** (Recommandé).
3. Notre workflow `.github/workflows/pages.yml` se chargera de compiler et de pousser automatiquement le contenu du dossier `/public` à chaque modification ou nouveau lead détecté.

---

## Étape 5 : Premier Lancement de l'Automatisation
1. Dans l'onglet **Actions** de votre dépôt GitHub.
2. Sélectionnez le workflow **Client Radar OS** à gauche.
3. Cliquez sur le bouton déroulant **Run workflow** à droite, puis validez.
4. Cela lancera le script de recherche Python une première fois pour générer les fichiers initiaux `leads.json`, les statistiques, ainsi que les pages HTML dans `public/offers/`.

---

## Étape 6 : Compiler et Installer l'Application Flutter
1. Ouvrez un terminal dans le dossier `/app_flutter`.
2. Assurez-vous d'avoir le SDK Flutter installé.
3. Branchez votre smartphone Android en mode débogage USB ou lancez un émulateur.
4. Téléchargez les dépendances du projet :
   ```bash
   flutter pub get
   ```
5. Lancez l'application sur votre appareil de test :
   ```bash
   flutter run --release
   ```
   *(Vous pouvez également générer l'APK pour l'installer directement sur votre smartphone via `flutter build apk`).*

---

## Étape 7 : Configurer la Synchronisation Mobile
1. À l'ouverture de l'application sur votre téléphone, passez l'onboarding et ouvrez l'écran **Paramètres GitHub**.
2. Remplissez les champs de configuration :
   *   **Utilisateur GitHub :** Votre pseudo GitHub.
   *   **Nom du dépôt :** `client-radar-os-private`.
   *   **Branche :** `main`.
   *   **Token d'accès (PAT) :** Saisissez un jeton GitHub d'accès personnel avec les droits `repo` (Généré dans GitHub *Settings* > *Developer Settings* > *Personal Access Tokens*).
3. Cliquez sur **Tester connexion** pour valider la communication.
4. Cliquez sur **Enregistrer**.
5. Retournez sur le tableau de bord (Dashboard) et cliquez sur l'icône de synchronisation (en haut à droite) : toutes vos opportunités de prospects ainsi que les statistiques sont importées directement de GitHub dans l'application mobile locale SQLite !
