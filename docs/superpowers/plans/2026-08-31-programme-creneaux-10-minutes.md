# Programme CINI avec créneaux de 10 minutes — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Afficher chaque communication scientifique sur 10 minutes et ajouter après chaque session un bloc transversal de discussion égal à cinq minutes par communication.

**Architecture:** `_data/program.yml` demeure la source canonique des horaires. Une fiche de programme unique représente les discussions collectives, tandis que le JavaScript existant transforme leurs cartes en bandeaux couvrant les deux colonnes, sans les inclure aux résultats de recherche.

**Tech Stack:** Jekyll, YAML, Liquid, JavaScript ES5, Ruby pour les validations.

## Global Constraints

- Conserver l’ordre et la modalité actuels des communications.
- Ne pas modifier les durées des discours, pauses, déjeuner, keynote, témoignages et clôture.
- Chaque communication scientifique dure exactement 10 minutes.
- Chaque discussion dure cinq minutes multipliées par le nombre de communications de sa session.
- Les discussions couvrent visuellement les deux colonnes et ne figurent pas dans la recherche.

---

### Task 1: Tests de structure et de durée

**Files:**
- Modify: `_tools/test_session_program.rb`

- [ ] Remplacer les assertions interdisant les discussions par des assertions exigeant six blocs « Discussion collective et questions ».
- [ ] Vérifier les six durées attendues : 25, 30, 15, 30, 45 et 35 minutes.
- [ ] Vérifier que toutes les communications CMT programmées durent 10 minutes.
- [ ] Exécuter `ruby _tools/test_session_program.rb` et confirmer l’échec avant implémentation.

### Task 2: Horaires et fiche de discussion

**Files:**
- Modify: `_data/program.yml`
- Create: `_talks/discussion-collective.md`
- Modify: `program/index.md`

- [ ] Redistribuer les horaires de chaque session en blocs consécutifs de 10 minutes sans modifier son début ni sa fin.
- [ ] Ajouter la discussion à la fin de chacune des six sessions avec la durée calculée.
- [ ] Créer la fiche « Discussion collective et questions » dans la catégorie Discussions.
- [ ] Simplifier la notice pour annoncer les présentations de 10 minutes et les discussions explicites.
- [ ] Exécuter les tests Ruby et confirmer leur réussite.

### Task 3: Bandeaux de discussion transversaux

**Files:**
- Modify: `assets/js/program-search.js`
- Modify: `program/index.md`

- [ ] Identifier les cartes dont le lien cible `/talks/discussion-collective/`.
- [ ] Transformer chaque ligne correspondante en une cellule de cinq colonnes avec la classe `program-discussion-row`.
- [ ] Ajouter un style distinct et responsive au bandeau de discussion.
- [ ] Exclure explicitement les cartes de discussion des résultats de recherche.

### Task 4: Validation finale

**Files:**
- Test: `_tools/validate_2026_content.rb`
- Test: `_tools/test_session_program.rb`
- Test: `_tools/test_program_search.rb`

- [ ] Exécuter les trois scripts Ruby.
- [ ] Générer le site avec `bundle exec jekyll build`.
- [ ] Vérifier dans le HTML généré les six discussions, les horaires de 10 minutes, les bandeaux transversaux et l’absence des discussions dans les données de recherche.
- [ ] Exécuter `git diff --check`.
