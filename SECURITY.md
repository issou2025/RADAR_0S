# Security Policy - Client Radar OS

Ce document présente les directives de sécurité indispensables pour exploiter l'application **Client Radar OS** en toute confidentialité.

## Principes de Sécurité Majeurs

### 1. Dépôt GitHub Privé Obligatoire
*   **Règle d'or :** Ne rendez **jamais** ce dépôt public.
*   Ce projet contient des informations confidentielles sur vos prospects, vos notes privées, vos propositions commerciales et la structure de votre serveur statique. Le nom du dépôt configuré doit être : `client-radar-os-private`.

### 2. Gestion des Clés API et Tokens
*   **Ne jamais commiter de clés d'accès en clair** dans le code source ou dans les fichiers de configuration JSON (`settings.json` ou autre).
*   Pour l'automation (GitHub Actions), enregistrez toutes les clés d'API (Google CSE, Reddit, Freelancer) en tant que **Secrets de dépôt** (Repository Secrets) dans les paramètres GitHub de votre projet.
*   Pour l'application mobile (Flutter), le Token d'Accès Personnel GitHub (PAT) est stocké de manière chiffrée sur la puce de sécurité du téléphone (Android Keystore) via le package `flutter_secure_storage`. Aucun serveur tiers ne peut y accéder.

### 3. Permissions Limitées du Token GitHub (PAT)
Lorsque vous créez le token d'accès personnel GitHub (Fine-grained ou Classic) pour l'application mobile, accordez-lui uniquement les droits minimaux requis :
*   `repo` (Accès complet en lecture/écriture aux dépôts privés pour pouvoir modifier `user_actions.json` et lire `leads.json`).

### 4. Automatisation Ethique et Non-Scraping
*   **Pas d'envois automatisés :** L'application prépare les textes de réponse, mais c'est l'utilisateur humain qui effectue l'envoi. Ne cherchez pas à contourner cette sécurité pour éviter le bannissement de vos comptes de plateformes (Upwork, Freelancer, LinkedIn, Reddit, etc.).
*   **Pas de scraping LinkedIn :** LinkedIn interdit formellement le scraping de ses pages. Le radar n'interagit qu'avec des APIs publiques officielles autorisées ou des flux RSS ouverts.
*   **Respect de robots.txt :** Les scripts Python respectent les fichiers de configuration d'accès des robots et n'utilisent pas de navigateur invisible (headless browser) de contournement.

## Secrets GitHub Recommandés
Dans l'interface GitHub, allez dans `Settings` > `Secrets and variables` > `Actions` et configurez :
*   `GOOGLE_API_KEY` : Clé d'API Google Cloud Console.
*   `GOOGLE_CSE_ID` : Identifiant unique de votre moteur Google Custom Search.
*   `REDDIT_CLIENT_ID` / `REDDIT_CLIENT_SECRET` (Facultatif) : Identifiants API Reddit.
*   `X_BEARER_TOKEN` (Facultatif) : Clé API Twitter/X.
*   `FREELANCER_TOKEN` (Facultatif) : Clé de connexion API Freelancer.
