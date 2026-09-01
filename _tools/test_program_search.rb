# frozen_string_literal: true

program_page = File.read('_site/program/index.html')
search_script = File.read('assets/js/program-search.js')

checks = {
  'search input' => 'id="program-search"',
  'clear button' => 'id="program-search-clear"',
  'result count' => 'id="program-search-status"',
  'compact results' => 'id="program-search-results"',
  'cache-busted search script' => %r{src="/assets/js/program-search\.js\?t=\d+"}
}

missing = checks.reject do |_name, marker|
  marker.is_a?(Regexp) ? program_page.match?(marker) : program_page.include?(marker)
end.keys
abort "Missing program search: #{missing.join(', ')}" unless missing.empty?

abort 'Program search does not index the room modality.' unless search_script.include?("getAttribute('data-room')")
abort 'Program search does not replace the timetable with compact results.' unless search_script.include?('program-search-active')
abort 'Program search does not rank title matches.' unless search_script.include?('title: 100')
abort 'Program search does not rank abstract matches last.' unless search_script.include?('abstract: 10')
abort 'Program search does not label abstract-only matches.' unless search_script.include?('Correspondance trouvée dans le résumé')

search_data = program_page[/<script id="program-search-data"[^>]*>(.*?)<\/script>/m, 1]
abort 'Program search index is not structured by field.' unless search_data&.include?('"title":') && search_data.include?('"abstract":')

search_position = program_page.index('id="program-search"')
abort 'Search bar is missing from the program introduction.' unless search_position
abort 'Expandable scientific-session details are missing.' unless program_page.include?('scientific-sessions-details')
abort 'Search does not use the original timetable cards.' unless search_script.include?("querySelectorAll('.tab-pane tbody td.alert')")
abort 'Session labels do not span the original grid.' unless search_script.include?('program-session-row') && search_script.include?('colSpan = 5')
abort 'Discussion blocks do not span the original grid.' unless search_script.include?('program-discussion-row') && search_script.include?("/talks/discussion-collective/") && search_script.include?('card.colSpan = 5')
abort 'Discussion blocks are not excluded from search results.' unless search_script.include?('discussionCards.indexOf(card) === -1')
abort 'Program page does not expose session metadata.' unless program_page.include?('id="program-session-data"')

puts 'Program search markup is present.'
