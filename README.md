# Client Radar OS 📡

> **Find clients before they find freelancers.**
> Application privée de détection, qualification et conversion de prospects freelance, synchronisée avec GitHub, sans serveur, sans Firebase, sans Supabase.

---

## 📖 Présentation du Projet
**Client Radar OS** est une solution conçue pour les freelances cherchant à identifier rapidement des opportunités de missions sur Internet. L'application surveille diverses sources publiques (Recherche Google, flux RSS, APIs d'enquêtes de dépôts publics), filtre le bruit, attribue un score de qualification commerciale, prépare des propositions professionnelles sur-mesure et publie des pages d'offres portfolio statiques sur **GitHub Pages**.

Le système fonctionne entièrement en **Serverless** (sans base de données payante ni backend dédié) en s'appuyant sur :
*   Un dépôt **GitHub Privé** comme base de données distante (fichiers JSON).
*   **GitHub Actions** comme moteur automatisé de recherche périodique (scripts Python toutes les 6 heures).
*   **GitHub Pages** comme outil d'hébergement gratuit des pages d'offres commerciales statiques.
*   Une application mobile **Android Flutter** connectée au dépôt GitHub via l'API REST officielle, stockant les données en local dans une base **SQLite**.

---

## 🛠️ Architecture du Dépôt

```
client-radar-os-private/
│
├── app_flutter/            # Application mobile Android Flutter
│   ├── lib/
│   │   ├── main.dart       # Point d'entrée de l'application
│   │   ├── app.dart        # Routeur et thème global
│   │   ├── core/           # Constantes, Thème, Chiffrement Secure Storage
│   │   ├── data/           # SQLite, GitHub Remote DataSource, Repositories, Modèles
│   │   └── features/       # Écrans de l'interface (Tableau de bord, Kanban, Studio, etc.)
│   └── pubspec.yaml
│
├── data/                   # Fichiers de données (Stockage distant JSON)
│   ├── leads.json          # Base de données master des opportunités détectées
│   ├── keywords.json       # Liste de mots-clés d'intention et d'exclusion
│   ├── sources.json        # Fichier de configuration des sources actives
│   ├── user_actions.json   # Journal des actions utilisateur en attente de fusion
│   ├── reply_templates.json # Modèles de messages de prospection (FR/EN)
│   └── stats.json          # Statistiques commerciales générées
│
├── scripts/                # Scripts Python d'automatisation
│   ├── main.py             # Script principal (Orchestrateur)
│   ├── search_*.py         # Modules de recherche (Google, GitHub, RSS, etc.)
│   ├── score_leads.py      # Engin de scoring et évaluation du risque (0-100)
│   ├── need_decoder.py     # Extraction des besoins, questions et estimation des prix
│   ├── reply_generator.py  # Génération des versions de courriels (Short, Prof, etc.)
│   ├── offer_page_generator.py # Générateur de landing pages HTML statiques
│   ├── proposal_builder.py # Créateur de propositions commerciales au format Markdown
│   └── stats_generator.py  # Calcul des performances et rapport hebdomadaire
│
├── public/                 # Contenu statique publié sur GitHub Pages
│   ├── index.html          # Index d'accueil du Portfolio Freelance
│   ├── style.css           # Feuille de style du portfolio (Glassmorphism)
│   └── offers/             # 10 pages d'offres ciblant des services spécifiques
│
├── reports/                # Rapports périodiques d'activité
│   └── weekly/             # Rapports hebdomadaires Markdown
│
├── .github/                # Workflows GitHub Actions
│   └── workflows/
│       ├── radar.yml       # Lancement périodique du script de détection
│       └── pages.yml       # Déploiement automatique du portfolio sur GitHub Pages
│
├── SECURITY.md             # Directives de sécurité et politique d'accès
└── INSTALLATION.md         # Guide pas-à-pas pour démarrer
```

---

## 🔄 Protocole de Synchronisation (Bi-directionnel)

Pour se passer de base de données en temps réel, l'application utilise une architecture asynchrone décentralisée :

```
[Flutter Mobile] --(Modifie lead/status)--> [SQLite Locale] & [File d'actions SQLite]
       │
   (Sync)
       ▼
[GitHub user_actions.json] <--(Fusionne les actions locales)
       │
  (Toutes les 6h)
       ▼
[GitHub Actions (Python)] 
  1. Lit user_actions.json & Applique les nouveaux statuts dans leads.json
  2. Vide user_actions.json (Master Reset)
  3. Recherche de nouveaux prospects sur Internet
  4. Qualifie, score, rédige les propositions et landing pages
  5. Commite leads.json, stats.json et public/ sur GitHub
```

---

## 🔒 Limites & Sécurité
*   **Contrôle Final Humain :** L'application ne procède à aucun envoi de message automatique pour éviter d'enfreindre les conditions d'utilisation des plateformes et bloquer vos comptes. Vous copiez/collez les messages qualifiés ou partagez le lien d'offre généré.
*   **Vie Privée :** Aucune donnée personnelle nominative n'est extraite des plateformes publiques sans accord ou API officielle. Les analyses se basent uniquement sur la description publique des besoins du client.
*   **Secrets de Sécurité :** Toutes vos clés privées d'API Google, Reddit, etc. sont sécurisées dans l'onglet *Secrets* de GitHub.

---
*Client Radar OS - Find clients before they find freelancers.*
