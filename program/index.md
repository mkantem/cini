---
layout: program
---

<!-- The main categories (or tracks) of the different talks as well as their coloring can be adapted in the `_config.yml` file under `conference.talks.main_categories`. See also the [Talk Settings](https://github.com/DigitaleGesellschaft/jekyll-theme-conference/#talk-settings-main-categories) section of the theme's README file. -->

Date: **09-10 Septembre 2026**

Lieu: Institut des Sciences Humaines du Mali -- [ISH](https://ish.edu.ml){:target="_blank"} -- **Sotuba**

<div class="alert alert-light border text-center py-2" role="note">
  <strong>Fuseau horaire :</strong> GMT (UTC+0) — heure de Bamako
</div>

<div class="alert alert-success text-center py-2" role="note">
  <strong>Programme final.</strong>
</div>

<div class="alert alert-info alert-dismissible fade show" role="alert">
  Chaque communication dispose de <strong>10 minutes</strong>. Un temps de <strong>discussion collective et de questions</strong> est organisé à la fin de chaque session. Sa durée, indiquée dans la grille, est adaptée au nombre de communications programmées.
  <button type="button" class="close" data-dismiss="alert" aria-label="Fermer"><span aria-hidden="true">&times;</span></button>
</div>

<div class="alert alert-secondary alert-dismissible fade show" role="alert">
  Chaque session scientifique est conduite par une modératrice ou un modérateur chargé du <strong>respect du temps</strong>, de la <strong>distribution de la parole</strong> et de l’organisation des questions et réponses. Le nom de la modératrice ou du modérateur de chaque session est indiqué dans le programme.
  <button type="button" class="close" data-dismiss="alert" aria-label="Fermer"><span aria-hidden="true">&times;</span></button>
</div>

<style>
  body.program-search-active #day-list,
  body.program-search-active #day-content {
    display: none !important;
  }
  .session-toggle-icon {
    display: inline-block;
    transition: transform .2s ease;
  }
  [aria-expanded="true"] .session-toggle-icon {
    transform: rotate(180deg);
  }
  .program-session-row td {
    border-top: 0;
  }
  .program-session-label {
    line-height: 1.25;
  }
  .program-discussion-row td {
    border-top: 0;
  }
  .program-discussion-cell .alert {
    margin-bottom: .5rem;
    text-align: center;
  }
  .program-discussion-time {
    display: block;
    margin-top: .25rem;
  }
</style>

<script id="program-search-data" type="application/json">
{
  {% for talk in site.talks %}
    {% assign content_parts = talk.content | split: '<h2 id="mots-clés">Mots-clés</h2>' %}
    {% assign keyword_parts = content_parts[1] | split: '<h2 id="informations">Informations</h2>' %}
    {{ talk.url | jsonify }}: {
      "title": {{ talk.name | jsonify }},
      "speakers": {{ talk.speakers | join: ' ' | jsonify }},
      "keywords": {{ keyword_parts[0] | strip_html | jsonify }},
      "track": {{ talk.track | append: ' ' | append: talk.categories | jsonify }},
      "mode": {{ talk.presentation_mode | jsonify }},
      "abstract": {{ content_parts[0] | strip_html | jsonify }}
    }{% unless forloop.last %},{% endunless %}
  {% endfor %}
}
</script>
<script id="program-session-data" type="application/json">
[
  {% for day in site.data.program.days %}
    {% for room in day.rooms %}
      {% for slot in room.talks %}
        {% if slot.session %}
          {"talk": {{ slot.name | jsonify }}, "session": {{ slot.session | jsonify }}, "moderator": {{ slot.moderator | jsonify }}},
        {% endif %}
      {% endfor %}
    {% endfor %}
  {% endfor %}
  {}
]
</script>
<script defer src="{{ '/assets/js/program-search.js' | relative_url }}?t={{ site.time | date: '%s' }}"></script>

<div class="text-center mb-3">
  <button class="btn btn-info" type="button" data-toggle="collapse" data-target="#scientific-sessions-details" aria-expanded="false" aria-controls="scientific-sessions-details">
    Afficher les sessions scientifiques et la modération
    <span class="session-toggle-icon ml-1" aria-hidden="true">▼</span>
  </button>
  <div id="scientific-sessions-details" class="collapse">
    <div class="card card-body mt-2 text-left">
      <ul class="mb-0">
        <li><strong>Mercredi 12:00–13:15</strong> — Savoirs locaux, médiation et réconciliation — <strong>Modération :</strong> Dr Macire KANTE</li>
        <li><strong>Mercredi 14:15–15:10</strong> — Comprendre les conflits par les sciences sociales — <strong>Modération :</strong> Dr Sekou CAMARA</li>
        <li><strong>Mercredi 15:10–15:45</strong> — Territoires, institutions et gouvernance des conflits — <strong>Modération :</strong> Dr Amadou DIABATE</li>
        <li><strong>Jeudi 09:00–09:55</strong> — Approches critiques et interdisciplinaires — <strong>Modération :</strong> Dr Silamakan KANTE</li>
        <li><strong>Jeudi 10:25–11:40</strong> — Conflits, résilience et développement socio-économique — <strong>Modération :</strong> Dr Soumaila Oulalé</li>
        <li><strong>Jeudi 11:40–12:45</strong> — Santé, systèmes de santé et populations vulnérables — <strong>Modération :</strong> Dr Mahamadou KANTE</li>
      </ul>
    </div>
  </div>
</div>

<div class="program-search my-4" role="search" aria-labelledby="program-search-label">
  <label id="program-search-label" for="program-search" class="font-weight-bold">Rechercher dans le programme</label>
  <div class="input-group">
    <input id="program-search" class="form-control" type="search" placeholder="Titre, intervenant, thème ou modalité" autocomplete="off" aria-describedby="program-search-status">
    <div class="input-group-append">
      <button id="program-search-clear" class="btn btn-outline-secondary" type="button">Effacer</button>
    </div>
  </div>
  <p id="program-search-status" class="small text-muted mt-2 mb-0" aria-live="polite"></p>
</div>

<div id="program-search-results" class="row" aria-live="polite"></div>
