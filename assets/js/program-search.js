(function () {
  'use strict';

  function normalize(value) {
    return (value || '')
      .toString()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .toLowerCase();
  }

  function initProgramSearch() {
    var input = document.getElementById('program-search');
    var clearButton = document.getElementById('program-search-clear');
    var status = document.getElementById('program-search-status');
    var dataElement = document.getElementById('program-search-data');
    var results = document.getElementById('program-search-results');

    if (!input || !clearButton || !status || !dataElement || !results) return;

    var talkData = JSON.parse(dataElement.textContent || '{}');
    var allCards = Array.prototype.slice.call(
      document.querySelectorAll('.tab-pane tbody td.alert')
    );
    var discussionCards = allCards.filter(function (card) {
      var link = card.querySelector('a[href*="/talks/discussion-collective/"]');
      return Boolean(link);
    });
    var cards = allCards.filter(function (card) {
      return discussionCards.indexOf(card) === -1;
    });

    var sessionDataElement = document.getElementById('program-session-data');
    var sessionData = sessionDataElement ? JSON.parse(sessionDataElement.textContent || '[]') : [];
    sessionData.forEach(function (item) {
      if (!item.talk) return;
      var card = cards.find(function (candidate) {
        var link = candidate.querySelector('a[href*="/talks/"]');
        return link && link.textContent.trim() === item.talk;
      });
      if (!card) return;

      var talkRow = card.closest('tr');
      if (!talkRow || !talkRow.parentNode) return;

      var sessionRow = document.createElement('tr');
      sessionRow.className = 'program-session-row';
      var sessionCell = document.createElement('td');
      sessionCell.colSpan = 5;
      sessionCell.className = 'p-0';
      var label = document.createElement('div');
      label.className = 'program-session-label alert alert-info text-center py-2 px-3 mb-2';
      var title = document.createElement('strong');
      title.textContent = 'Session : ' + item.session;
      var moderator = document.createElement('span');
      moderator.className = 'd-block mt-1';
      moderator.textContent = 'Modération : ' + item.moderator;
      label.appendChild(title);
      label.appendChild(moderator);
      sessionCell.appendChild(label);
      sessionRow.appendChild(sessionCell);
      talkRow.parentNode.insertBefore(sessionRow, talkRow);
    });

    discussionCards.forEach(function (card) {
      var row = card.closest('tr');
      if (!row) return;
      var rowSpan = Number(card.getAttribute('rowspan')) || 1;

      var liveButton = card.querySelector('[data-start][data-end]');
      var start = liveButton && Number(liveButton.getAttribute('data-start'));
      var end = liveButton && Number(liveButton.getAttribute('data-end'));
      if (liveButton) liveButton.classList.add('d-none');

      if (start && end) {
        var time = document.createElement('span');
        var format = new Intl.DateTimeFormat('fr-FR', {
          hour: '2-digit', minute: '2-digit', hour12: false, timeZone: 'UTC'
        });
        time.className = 'program-discussion-time small font-weight-bold';
        time.textContent = format.format(new Date(start * 1000)) + '–' + format.format(new Date(end * 1000));
        card.appendChild(time);
      }

      for (var index = 1; index < rowSpan; index += 1) {
        var followingRow = row.nextElementSibling;
        if (!followingRow) break;
        followingRow.parentNode.removeChild(followingRow);
      }
      while (row.firstChild) row.removeChild(row.firstChild);
      row.className = 'program-discussion-row';
      card.removeAttribute('rowspan');
      card.colSpan = 5;
      card.classList.add('program-discussion-cell');
      row.appendChild(card);
    });

    cards.forEach(function (card) {
      var talkLink = card.querySelector('a[href*="/talks/"]');
      var liveButton = card.querySelector('[data-room]');
      var fields = talkLink ? talkData[talkLink.getAttribute('href')] : {};
      var room = liveButton ? liveButton.getAttribute('data-room') : '';
      card.searchFields = {
        title: normalize(fields.title || (talkLink && talkLink.textContent)),
        speakers: normalize(fields.speakers || card.textContent),
        keywords: normalize(fields.keywords),
        track: normalize(fields.track),
        mode: normalize((fields.mode || '') + ' ' + room),
        abstract: normalize(fields.abstract)
      };
    });

    function resultCard(card, abstractOnly) {
      var talkLink = card.querySelector('a[href*="/talks/"]');
      var speaker = card.querySelector('p.font-weight-light');
      var liveButton = card.querySelector('[data-room]');
      var start = liveButton && Number(liveButton.getAttribute('data-start'));
      var room = liveButton ? liveButton.getAttribute('data-room') : '';
      var time = start ? new Intl.DateTimeFormat('fr-FR', {
        weekday: 'long', hour: '2-digit', minute: '2-digit', timeZone: 'UTC'
      }).format(new Date(start * 1000)) : '';
      var column = document.createElement('div');

      column.className = 'col-12 col-lg-6 mb-3';
      column.innerHTML = '<article class="card h-100 shadow-sm"><div class="card-body">' +
        '<h3 class="h5 card-title"><a href="' + talkLink.href + '">' + talkLink.textContent.trim() + '</a></h3>' +
        (speaker && speaker.textContent.trim() ? '<p class="card-text mb-2">' + speaker.textContent.trim() + '</p>' : '') +
        '<p class="card-text small text-muted mb-0 text-capitalize">' + time + (room ? ' · ' + room : '') + '</p>' +
        (abstractOnly ? '<p class="card-text small text-info mt-2 mb-0">Correspondance trouvée dans le résumé</p>' : '') +
        '</div></article>';
      return column;
    }

    function relevance(card, terms) {
      var weights = { title: 100, speakers: 80, keywords: 60, track: 40, mode: 30, abstract: 10 };
      var score = 0;
      var primaryMatch = false;

      for (var i = 0; i < terms.length; i += 1) {
        var bestWeight = 0;
        Object.keys(weights).forEach(function (field) {
          if (card.searchFields[field].indexOf(terms[i]) !== -1) {
            bestWeight = Math.max(bestWeight, weights[field]);
            if (field !== 'abstract') primaryMatch = true;
          }
        });
        if (!bestWeight) return null;
        score += bestWeight;
      }

      return { card: card, score: score, abstractOnly: !primaryMatch };
    }

    function filterProgram() {
      var terms = normalize(input.value).trim().split(/\s+/).filter(Boolean);
      var matchingCards = [];

      cards.forEach(function (card, index) {
        var match = relevance(card, terms);
        if (match) {
          match.scheduleOrder = index;
          matchingCards.push(match);
        }
      });
      matchingCards.sort(function (left, right) {
        return right.score - left.score || left.scheduleOrder - right.scheduleOrder;
      });

      document.body.classList.toggle('program-search-active', terms.length > 0);
      results.innerHTML = '';

      if (terms.length) {
        matchingCards.forEach(function (match) {
          results.appendChild(resultCard(match.card, match.abstractOnly));
        });
        if (!matchingCards.length) {
          results.innerHTML = '<div class="col-12"><div class="alert alert-warning">Aucune communication ne correspond à cette recherche.</div></div>';
        }
      }

      status.textContent = terms.length
        ? matchingCards.length + (matchingCards.length === 1 ? ' résultat' : ' résultats')
        : 'Saisissez un titre, un intervenant, un thème ou une modalité.';
    }

    input.addEventListener('input', filterProgram);
    clearButton.addEventListener('click', function () {
      input.value = '';
      filterProgram();
      input.focus();
    });

    filterProgram();
  }

  document.addEventListener('DOMContentLoaded', initProgramSearch);
}());
