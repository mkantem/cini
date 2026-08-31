# Grille du programme avec communications de 10 minutes

## Objectif

Faire correspondre la grille visuelle au temps de parole réel décidé par le comité scientifique : chaque communication scientifique dispose de 10 minutes, puis les cinq minutes libérées par communication sont regroupées dans un bloc explicite de discussion collective à la fin de sa session.

## Périmètre

La modification concerne uniquement les communications scientifiques regroupées en sessions. Les discours officiels, la photo de famille, les pauses, le déjeuner, le keynote d’Olivier Douville, les témoignages et la clôture conservent leurs durées actuelles.

## Règles de programmation

1. Chaque communication scientifique occupe un créneau de 10 minutes dans `_data/program.yml`.
2. L’ordre actuel des communications et leur modalité — présentiel ou en ligne — sont conservés.
3. Après la dernière communication de chaque session, une entrée intitulée « Discussion collective et questions » est ajoutée à la grille.
4. La durée de cette entrée est égale à cinq minutes multipliées par le nombre de communications de la session.
5. Les discussions sont des entrées communes à la session : elles ne sont attribuées ni à un intervenant ni à une modalité de présentation particulière.
6. Les horaires globaux des sessions restent, autant que possible, identiques à ceux du programme actuel. La transformation redistribue les créneaux existants sans rallonger artificiellement les journées.

## Présentation visuelle

Les communications continuent d’apparaître dans les colonnes « Salle de conférence de l’ISH » et « En ligne ». Le bloc de discussion doit être visuellement distinct et s’étendre sur les deux colonnes, comme les bandeaux de session, puisqu’il concerne l’ensemble des communications de la session hybride.

La notice placée au-dessus du programme indiquera clairement :

- 10 minutes de présentation par communication ;
- regroupement des cinq minutes restantes par communication ;
- discussion collective organisée à la fin de chaque session ;
- rôle de la modératrice ou du modérateur dans le respect du temps et la gestion des échanges.

## Recherche

Les blocs de discussion ne sont pas des communications scientifiques et ne doivent pas apparaître comme résultats dans la recherche du programme. Les communications restent recherchables par titre, intervenant, thème, modalité, mots-clés et résumé.

## Validation

Les contrôles automatiques devront vérifier :

- la présence de la règle des 10 minutes dans la notice ;
- l’absence de l’ancienne règle des créneaux visuels de 15 minutes ;
- la présence d’un bloc de discussion après chaque session scientifique ;
- le calcul correct de la durée des discussions ;
- le maintien de l’ordre des communications ;
- l’affichage des blocs de discussion sur les deux colonnes ;
- la validité des 37 communications et des 47 profils d’intervenants ;
- la génération complète du site Jekyll.
