# 🚀 GUIDE DÉPLOIEMENT COMPLET - Home-Page Helpdesk

## 📋 Checklist Déploiement

Suis ces étapes **dans l'ordre** pour déployer les 3 composants LWC en sandbox.

---

## ÉTAPE 1️⃣ - PRÉPARER LE REPO LOCAL

### 1.1 - Cloner/Accéder au repo

```bash
# Si tu n'as pas le repo localement
git clone https://github.com/ChrisT33850/Home-Page.git
cd Home-Page

# Aller sur la branche Helpdesk
git checkout Helpdesk
git pull origin Helpdesk
```

### 1.2 - Vérifier la structure

```bash
# Afficher l'arborescence
ls -la
```

Tu devrais voir quelque chose comme :
```
Home-Page/
├── .git/
├── force-app/
│   └── main/
│       └── default/
│           ├── classes/
│           ├── lwc/
│           └── ... (autres dossiers Salesforce)
└── ... (config files)
```

---

## ÉTAPE 2️⃣ - CRÉER LA STRUCTURE DES DOSSIERS

### 2.1 - Créer les dossiers LWC

```bash
# Naviguer dans le dossier lwc
cd force-app/main/default/lwc

# Créer les 3 dossiers composants
mkdir helpdeskKanban
mkdir agentsOnline
mkdir helpdeskHomePage

# Retour au root
cd ../../../../
```

### 2.2 - Vérifier la structure créée

```bash
ls -la force-app/main/default/lwc/
```

Résultat attendu :
```
helpdeskKanban/
agentsOnline/
helpdeskHomePage/
```

---

## ÉTAPE 3️⃣ - AJOUTER LES FICHIERS LWC

### 3.1 - Composant KANBAN

Copie ces 4 fichiers dans `force-app/main/default/lwc/helpdeskKanban/` :

**Fichiers à copier :**
1. `helpdeskKanban.js`
2. `helpdeskKanban.html`
3. `helpdeskKanban.css`
4. `helpdeskKanban.js-meta.xml`

```bash
# Depuis le repo root
cd force-app/main/default/lwc/helpdeskKanban/

# Copie les 4 fichiers que tu as téléchargés
# (copier les fichiers manuellement ou via terminal)

cd ../../../../
```

### 3.2 - Composant AGENTS ONLINE

Copie ces 4 fichiers dans `force-app/main/default/lwc/agentsOnline/` :

**Fichiers à copier :**
1. `agentsOnline.js`
2. `agentsOnline.html`
3. `agentsOnline.css`
4. `agentsOnline.js-meta.xml`

```bash
cd force-app/main/default/lwc/agentsOnline/
# Copie les 4 fichiers
cd ../../../../
```

### 3.3 - Composant HOME PAGE (optionnel - ancien)

Si tu veux garder le premier composant, copie dans `force-app/main/default/lwc/helpdeskHomePage/` :

**Fichiers à copier :**
1. `helpdeskHomePage.js`
2. `helpdeskHomePage.html`
3. `helpdeskHomePage.css`
4. `helpdeskHomePage.js-meta.xml`

```bash
cd force-app/main/default/lwc/helpdeskHomePage/
# Copie les 4 fichiers
cd ../../../../
```

---

## ÉTAPE 4️⃣ - AJOUTER LES CLASSES APEX

### 4.1 - Créer les fichiers Apex

Copie ces 2 fichiers dans `force-app/main/default/classes/` :

**Fichiers à copier :**
1. `HelpdeskKanbanController.cls` (du fichier `HelpdeskKanbanController.apex`)
2. `AgentsOnlineController.cls` (du fichier `AgentsOnlineController.apex`)

```bash
cd force-app/main/default/classes/

# Créer les fichiers .cls
# (Copie le contenu .apex en tant que .cls)
```

### 4.2 - Créer les fichiers META XML pour Apex

**Créer `HelpdeskKanbanController.cls-meta.xml` :**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

**Créer `AgentsOnlineController.cls-meta.xml` :**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>59.0</apiVersion>
    <status>Active</status>
</ApexClass>
```

### 4.3 - Vérifier la structure

```bash
cd ../../../../
ls -la force-app/main/default/classes/
```

Résultat attendu :
```
HelpdeskKanbanController.cls
HelpdeskKanbanController.cls-meta.xml
AgentsOnlineController.cls
AgentsOnlineController.cls-meta.xml
(+ autres classes existantes)
```

---

## ÉTAPE 5️⃣ - VÉRIFIER LA STRUCTURE FINALE

```bash
# Depuis repo root
tree force-app/main/default/ -L 3

# OU avec ls (plus simple)
echo "=== LWC ==="
ls -la force-app/main/default/lwc/
echo ""
echo "=== CLASSES ==="
ls -la force-app/main/default/classes/
```

**Structure finale attendue :**

```
force-app/main/default/
├── classes/
│   ├── AgentsOnlineController.cls
│   ├── AgentsOnlineController.cls-meta.xml
│   ├── HelpdeskKanbanController.cls
│   ├── HelpdeskKanbanController.cls-meta.xml
│   └── (autres classes...)
├── lwc/
│   ├── agentsOnline/
│   │   ├── agentsOnline.js
│   │   ├── agentsOnline.html
│   │   ├── agentsOnline.css
│   │   └── agentsOnline.js-meta.xml
│   ├── helpdeskKanban/
│   │   ├── helpdeskKanban.js
│   │   ├── helpdeskKanban.html
│   │   ├── helpdeskKanban.css
│   │   └── helpdeskKanban.js-meta.xml
│   ├── helpdeskHomePage/
│   │   ├── helpdeskHomePage.js
│   │   ├── helpdeskHomePage.html
│   │   ├── helpdeskHomePage.css
│   │   └── helpdeskHomePage.js-meta.xml
│   └── (autres composants...)
└── (autres dossiers...)
```

---

## ÉTAPE 6️⃣ - COMMIT & PUSH VERS GITHUB

### 6.1 - Vérifier les changements

```bash
# Depuis repo root
git status
```

Tu devrais voir les fichiers **Untracked** ou **Modified** :
```
Untracked files:
  force-app/main/default/lwc/helpdeskKanban/
  force-app/main/default/lwc/agentsOnline/
  force-app/main/default/classes/AgentsOnlineController.cls
  force-app/main/default/classes/HelpdeskKanbanController.cls
```

### 6.2 - Add les fichiers

```bash
git add force-app/main/default/lwc/helpdeskKanban/
git add force-app/main/default/lwc/agentsOnline/
git add force-app/main/default/classes/HelpdeskKanbanController.*
git add force-app/main/default/classes/AgentsOnlineController.*

# OU ajouter tout
git add force-app/
```

### 6.3 - Commit

```bash
git commit -m "feat: ajout composants LWC Kanban + Agents Online avec Omnichannel Presence"
```

### 6.4 - Push vers GitHub

```bash
git push origin Helpdesk
```

Vérifier : https://github.com/ChrisT33850/Home-Page/tree/Helpdesk

---

## ÉTAPE 7️⃣ - DÉPLOYER VIA GEARSET

### 7.1 - Ouvrir Gearset

1. Va sur https://www.gearset.com
2. Connecte-toi avec ton compte
3. Sélectionne le repo **Home-Page** (branche Helpdesk)

### 7.2 - Créer un Deployment

1. Clique sur **"Deploy"**
2. **Source** : Repository (GitHub)
3. **Target** : Sandbox (christophe.trevise@acteongroup.com.partial)

### 7.3 - Sélectionner les fichiers

**Cherche et sélectionne :**

✅ `HelpdeskKanbanController.cls` + `-meta.xml`  
✅ `AgentsOnlineController.cls` + `-meta.xml`  
✅ Dossier complet `helpdeskKanban` (lwc)  
✅ Dossier complet `agentsOnline` (lwc)  

**Optionnel :**
- `helpdeskHomePage` (ancien composant - garder ou ignorer)

### 7.4 - Valider les changements

1. Gearset affiche les **Differences**
2. Clique **"Next"** pour continuer
3. Vérifie que tout est vert ✅
4. Clique **"Deploy"**

### 7.5 - Attendre le déploiement

- Gearset affiche la progression
- Attends que tout passe ✅
- **Succès** = tous les fichiers déployés

---

## ÉTAPE 8️⃣ - CONFIGURER DANS SALESFORCE

### 8.1 - Ajouter les composants à la Home Page

1. Va dans ton **Sandbox** Salesforce
2. **Setup → Configurations Lightning → Pages d'accueil**
3. Crée une nouvelle page : **"Helpdesk Agent Dashboard"**

### 8.2 - Ajouter les composants

**Ajouter les 3 composants :**

1. **Agents En Ligne** (agentsOnline)
   - Affiche le statut des agents
   - Mets en haut

2. **Helpdesk Kanban Board** (helpdeskKanban)
   - Affiche le Kanban avec les queues
   - Mets au milieu

3. **Helpdesk Home Page** (helpdeskHomePage - optionnel)
   - Affiche les KPIs
   - Mets en bas (ou ignore)

### 8.3 - Sauvegarder et Assigner

1. Clique **"Save"**
2. Va dans **Setup → Profiles → Helpdesk Agent**
3. **Lightning Home Page** → Sélectionne **"Helpdesk Agent Dashboard"**
4. Sauvegarde

---

## ÉTAPE 9️⃣ - TESTER EN SANDBOX

### 9.1 - Accéder à la Home Page

1. Va à l'**accueil** du sandbox
2. Tu devrais voir les 3 sections :
   - 👥 **Agents En Ligne** (avec points colorés)
   - 📂 **Files d'Attente** (avec nombre de cases)
   - 🎯 **Tableau Kanban** (avec colonnes)

### 9.2 - Tester les features

**Agents Online :**
- ✅ Sélectionne une queue
- ✅ Vois les agents avec leurs statuts (🟢 vert, 🟠 orange, ⚫ gris)
- ✅ Clique Rafraîchir (devrait se mettre à jour auto)

**Kanban :**
- ✅ Sélectionne une queue
- ✅ Vois les colonnes (New, In Progress, Closed, etc.)
- ✅ Drag une case vers une autre colonne
- ✅ Le statut se met à jour en Salesforce

**Home Page (optionnel) :**
- ✅ Vois les KPIs (cas ouverts, fermés, en retard)

---

## ⚠️ DÉPANNAGE COURANT

### Erreur : "Component not found"

**Solution :**
- Vérifie que les fichiers `-meta.xml` existent pour chaque LWC
- Vérifie que `apiVersion` = `59.0` dans les `.js-meta.xml`

### Erreur : "Class not found"

**Solution :**
- Vérifie que `HelpdeskKanbanController.cls` et `AgentsOnlineController.cls` existent
- Vérifie les fichiers `-meta.xml` pour les classes Apex

### Les agents ne s'affichent pas

**Solution :**
- Assure-toi qu'il y a au moins une **Queue** créée
- L'utilisateur doit être **assigné à une queue**
- **Setup → Queues → Sélectionne une queue → Members → Ajoute l'utilisateur**

### Les statuts Omnichannel ne s'affichent pas

**Solution :**
- Vérifie que **Omnichannel Routing** est activé
- Vérifie que les **statuts de présence** sont créés (Available, Busy, etc.)
- **Setup → Omnichannel → Omnichannel Settings**

### Les cases du Kanban ne s'affichent pas

**Solution :**
- Vérifie qu'il y a des **cases** dans Salesforce
- Vérifie que le champ **`Kanban_Status__c`** existe sur Case
- Vérifie que la case a une valeur dans `Kanban_Status__c`

---

## ✅ RÉSUMÉ FINAL

Une fois tout déployé, tu devrais avoir :

✅ **Agents Online** - Liste des agents avec statuts Omnichannel  
✅ **Kanban Board** - Tableau Kanban drag-drop avec `Kanban_Status__c`  
✅ **Home Page** - KPIs et statistiques des cases  

Tout sur une **seule page d'accueil** accessible aux agents Helpdesk ! 🎉

---

## 🎯 PROCHAINES ÉTAPES

1. Déployer en Sandbox ✅ (ETapes 1-9 ci-dessus)
2. Tester les 3 composants
3. Ajuster les couleurs/icônes si besoin
4. Documenter dans ton SOP
5. Déployer en Production (même processus)

---

## 📞 BESOIN D'AIDE ?

Pour chaque étape, tu me dis :
- Quel est le problème exact ?
- Quel message d'erreur tu vois ?
- Quel composant est concerné ?

Je suis là ! 🚀
