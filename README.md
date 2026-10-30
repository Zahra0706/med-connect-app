# MedConnect

MedConnect est une solution complète de gestion médicale conçue pour simplifier et optimiser la relation entre les patients et les professionnels de santé. Cette application offre une plateforme fluide pour la prise de rendez-vous, la gestion des dossiers médicaux et la communication sécurisée.

## Fonctionnalités Principales

### Pour les Patients
*   **Prise de Rendez-vous** : Recherchez des médecins et réservez des consultations en quelques clics.
*   **Tableau de Bord** : Visualisez vos rendez-vous à venir, passés et annulés.
*   **Dossier Médical** : Accédez à votre historique médical et à vos documents (ordonnances, résultats d'analyses) en toute sécurité.
*   **Gestion de Profil** : Mettez à jour vos informations personnelles facilement.

### Pour les Médecins
*   **Gestion de Planning** : Visualisez et gérez votre emploi du temps et vos consultations.
*   **Suivi des Patients** : Accédez aux dossiers médicaux de vos patients pour un meilleur suivi.
*   **Confirmation de Rendez-vous** : Acceptez, refusez ou annulez les demandes de rendez-vous reçues.
*   **Tableau de Bord Pro** : Une vue d'ensemble de votre activité quotidienne.

##  Technologies Utilisées

Le projet est divisé en deux parties principales :

*   **Backend** : Développé avec **Django** et **Django REST Framework (DRF)**. Il gère l'authentification, la logique métier, la base de données et expose une API REST pour le frontend.
*   **Frontend** : Application mobile développée avec **Flutter (Dart)**, offrant une interface utilisateur native, réactive et performante sur Android et iOS.

## Guide d'Installation

Suivez ces étapes pour installer et lancer le projet localement.

### Prérequis
Assurez-vous d'avoir installé :
*   [Python 3.8+](https://www.python.org/downloads/)
*   [Flutter SDK](https://docs.flutter.dev/get-started/install)
*   [Git](https://git-scm.com/)

### 1. Backend (Django)

Naviguez dans le dossier du backend et configurez l'environnement virtuel.

```bash
cd medconnect-backend

# Création de l'environnement virtuel (Windows)
python -m venv my_venv

# Activation
.\my_venv\Scripts\activate

# Installation des dépendances
pip install -r requirements.txt

# Application des migrations
python manage.py migrate

# Lancement du serveur de développement
python manage.py runserver
```
Le serveur sera accessible à l'adresse `http://127.0.0.1:8000/`.

### 2. Frontend (Flutter)

Dans un nouveau terminal, naviguez vers le dossier du frontend.

```bash
cd medconnect-frontend

# Récupération des dépendances
flutter pub get

# Lancement de l'application
flutter run
```

## Authentification

L'application gère deux types d'utilisateurs distincts :
*   **Patients**
*   **Médecins**
(Il est recommandé de créer des super-utilisateurs via `python manage.py createsuperuser` pour l'administration backend).

---
*Ce projet a été réalisé dans le cadre d'un développement académique/personnel.*
