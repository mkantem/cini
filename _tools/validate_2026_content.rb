#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)
EXPECTED_TALKS = 28
EXPECTED_SPEAKERS = 43
REMOVED_PAPER_IDS = %w[1 2 4 5 6 11 14 16 17 27].freeze
REMOVED_SPEAKERS = [
  "Consolation TCHENGUELE SINAKA", "Eude Kaltani BOKOSSA", "LAURINE OCEANE DONGMO ZEBAZE",
  "Monique Kabanza Sebiguri", "KHALID CHERKAOUI SEMMOUNI", "OUALI Julbert", "Daouda SORE",
  "Issifou Abdourahamane Dabozi", "MBA MISSANG FREDERICK", "Fatoumata KEITA"
].freeze

def front_matter(path)
  source = File.read(path, encoding: "UTF-8")
  match = source.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  raise "Missing front matter: #{path}" unless match

  YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
end

talk_files = Dir[File.join(ROOT, "_talks", "cmt-*.md")]
speaker_files = Dir[File.join(ROOT, "_speakers", "*.md")]
errors = []

REMOVED_PAPER_IDS.each do |paper_id|
  errors << "Unpaid paper #{paper_id} still has a talk page" if File.exist?(File.join(ROOT, "_talks", "cmt-#{paper_id}.md"))
end

errors << "Expected #{EXPECTED_TALKS} CMT talks, found #{talk_files.length}" unless talk_files.length == EXPECTED_TALKS
errors << "Expected #{EXPECTED_SPEAKERS} speakers, found #{speaker_files.length}" unless speaker_files.length == EXPECTED_SPEAKERS

speakers = speaker_files.to_h do |path|
  data = front_matter(path)
  errors << "Speaker missing name: #{path}" if data["name"].to_s.strip.empty?
  [data["name"], path]
end
REMOVED_SPEAKERS.each do |name|
  errors << "Removed speaker #{name} still has a profile" if speakers.key?(name)
end

talks_by_name = {}
talks_by_id = {}
talk_files.each do |path|
  data = front_matter(path)
  errors << "Talk missing name: #{path}" if data["name"].to_s.strip.empty?
  errors << "Talk missing CMT paper_id: #{path}" if data["paper_id"].to_s.strip.empty?
  errors << "Talk missing speakers: #{path}" unless data["speakers"].is_a?(Array) && !data["speakers"].empty?
  Array(data["speakers"]).each do |name|
    errors << "Unknown speaker #{name.inspect} in #{path}" unless speakers.key?(name)
  end
  talks_by_name[data["name"]] = data
  talks_by_id[data["paper_id"].to_s] = data
end

config = File.read(File.join(ROOT, "_config.yml"), encoding: "UTF-8")
errors << "Navigation missing Intervenants" unless config.include?("name: Intervenants") && config.include?("relative_url: /speakers/")
errors << "Navigation missing Talks" unless config.include?("name: Talks") && config.include?("relative_url: /talks/")
errors << "Navigation missing Ressources" unless config.include?("name: Ressources")
errors << "Ressources missing downloads link" unless config.include?("name: Documents à télécharger") && config.include?("relative_url: /talks/downloads/")
errors << "Ressources missing submission information" unless config.include?("name: Informations de soumission") && config.include?("relative_url: /pages/soumission/")
errors << "Ressources missing CMT video guide" unless config.include?("name: Guide vidéo CMT") && config.include?("https://www.youtube.com/watch?v=7XLFslQgdU0")
errors << "Old Appel navigation remains" if config.include?("name: Appel (CFP)")
errors << "Navigation missing Programme" unless config.include?("name: Programme") && config.include?("relative_url: /program/")

scientific_committee = File.read(File.join(ROOT, "pages", "comite-scientifique", "index.md"), encoding: "UTF-8")
errors << "Scientific committee is missing its In memoriam section" unless scientific_committee.include?("### In memoriam")
errors << "In memoriam note must mention deaths during the organization" unless scientific_committee.include?("décédés au cours de l’organisation de cette édition")

home = File.read(File.join(ROOT, "index.md"), encoding: "UTF-8")
errors << "Homepage missing 40+ intervenants" unless home.include?("40+ intervenants")
errors << "Homepage missing closed-submissions notice" unless home.include?("Les soumissions sont closes")
errors << "Homepage scientific argumentaire was removed" unless home.include?("## 1. Argumentaire")
errors << "Homepage still promotes CMT submission" if config.include?("La soumission se fait exclusivement en ligne")
errors << "Homepage still promotes submission tutorial" if config.include?("Comment soumettre un résumé")

program_page = File.read(File.join(ROOT, "program", "index.md"), encoding: "UTF-8")
expected_moderators = ["Macire KANTE", "Sekou CAMARA", "Amadou DIABATE", "Silamakan KANTE", "Soumaila Oulalé", "Mahamadou KANTE"]
errors << "Confirmed moderators are missing from the session summary" unless expected_moderators.all? { |name| program_page.include?("<strong>Modération :</strong> #{name}") }
errors << "Unconfirmed moderator labels remain" if program_page.include?("<strong>Modération :</strong> À confirmer")
errors << "Moderator responsibilities are missing" unless program_page.include?("respect du temps") && program_page.include?("distribution de la parole")
errors << "Moderator notice still says names will be added later" if program_page.include?("Les noms seront ajoutés dès leur confirmation")
errors << "Moderator notice does not point to the published names" unless program_page.include?("Le nom de la modératrice ou du modérateur de chaque session est indiqué dans le programme")
errors << "Presentation-time banner is missing" unless program_page.include?("alert alert-info") && program_page.include?("Chaque communication dispose de <strong>10 minutes</strong>") && program_page.include?("adaptée au nombre de communications") && program_page.include?("discussion collective")
errors << "Moderator banner is missing" unless program_page.include?("alert alert-secondary") && program_page.include?("Chaque session scientifique est conduite")
errors << "Provisional-program warning is missing" unless program_page.include?("alert alert-danger alert-dismissible") && program_page.include?("Programme provisoire") && program_page.include?("susceptible de modifications") && program_page.include?("vendredi 4 septembre 2026")
errors << "Program banners must be dismissible" unless program_page.scan("alert-dismissible").length == 3

program = YAML.safe_load(File.read(File.join(ROOT, "_data", "program.yml"), encoding: "UTF-8"), permitted_classes: [Date], aliases: true)
scheduled = []
Array(program["days"]).each do |day|
  room_names = Array(day["rooms"]).map { |room| room["name"] }
  errors << "#{day["date"]} must show separate on-site and online rooms" unless room_names.include?("Salle de conférence de l’ISH") && room_names.include?("En ligne")
  Array(day["rooms"]).each do |room|
    room_slots = Array(room["talks"])
    room_slots.each do |slot|
      scheduled << slot.merge("date" => day["date"].to_s, "room" => room["name"])
    end
    room_slots.each_cons(2) do |previous, current|
      if current["time_start"] < previous["time_end"]
        errors << "Overlapping slots on #{day["date"]}: #{previous["name"]} and #{current["name"]}"
      end
    end
  end
end

scheduled_moderators = scheduled.select { |slot| slot["session"] }.sort_by { |slot| [slot["date"], slot["time_start"]] }.map { |slot| slot["moderator"] }
errors << "Confirmed moderators are assigned to the wrong sessions" unless scheduled_moderators == expected_moderators

discussion_slots = scheduled.select { |slot| slot["name"] == "Discussion collective et questions" }
errors << "Six collective discussion blocks are required" unless discussion_slots.length == 6
errors << "All collective discussions must last 15 minutes" unless discussion_slots.all? do |slot|
  start_hour, start_minute = slot["time_start"].split(":").map(&:to_i)
  end_hour, end_minute = slot["time_end"].split(":").map(&:to_i)
  (end_hour * 60 + end_minute) - (start_hour * 60 + start_minute) == 15
end

talks_by_id.each do |paper_id, talk|
  occurrences = scheduled.count { |slot| slot["name"] == talk["name"] }
  errors << "CMT paper #{paper_id} scheduled #{occurrences} times" unless occurrences == 1
end

talks_by_id.each do |paper_id, talk|
  scheduled_slot = scheduled.find { |slot| slot["name"] == talk["name"] }
  next unless scheduled_slot

  expected_room = talk["presentation_mode"] == "Ligne" ? "En ligne" : "Salle de conférence de l’ISH"
  errors << "CMT paper #{paper_id} is in the wrong visual room" unless scheduled_slot["room"] == expected_room
end

scheduled.each do |slot|
  next unless talks_by_name.key?(slot["name"])

  start_minutes = slot["time_start"].split(":").map(&:to_i).then { |h, m| h * 60 + m }
  end_minutes = slot["time_end"].split(":").map(&:to_i).then { |h, m| h * 60 + m }
  paper_id = talks_by_name[slot["name"]]["paper_id"].to_s
  expected_duration = paper_id == "13" ? 30 : 10
  errors << "CMT paper #{paper_id} visual slot is not #{expected_duration} minutes" unless end_minutes - start_minutes == expected_duration
end

%w[2026-09-09 2026-09-10].each do |date|
  lunch = scheduled.find { |slot| slot["date"] == date && slot["name"] == "Pause déjeuner" }
  expected_lunch = date == "2026-09-10" ? ["12:45", "13:45"] : ["13:15", "14:15"]
  errors << "Missing lunch on #{date}" unless lunch && lunch["time_start"] == expected_lunch[0] && lunch["time_end"] == expected_lunch[1]
  latest = scheduled.select { |slot| slot["date"] == date }.map { |slot| slot["time_end"] }.max
  expected_end = date == "2026-09-10" ? "16:10" : "16:30"
  errors << "Program ends after #{expected_end} on #{date}" if latest && latest > expected_end
end

errors << "Day 2 still contains the transversal round table" if scheduled.any? { |slot| slot["date"] == "2026-09-10" && slot["name"] == "Table ronde transversale" }
errors << "Transversal round table still exists in the talks collection" if File.exist?(File.join(ROOT, "_talks", "table-ronde-transversale.md"))
testimony_rooms = scheduled.select { |slot| slot["date"] == "2026-09-09" && slot["name"] == "Témoignages sur NIANGUIRY KANTÉ" }.map { |slot| slot["room"] }.sort
errors << "Testimonies must appear in both visual rooms" unless testimony_rooms == ["En ligne", "Salle de conférence de l’ISH"]
testimony = front_matter(File.join(ROOT, "_talks", "temoignages.md"))
expected_witnesses = ["Hamidou MAGASSA", "Fanta SOW", "Birama Djan DIAKITÉ", "Soumaila OULALE"]
errors << "Confirmed witnesses are missing" unless testimony["speakers"] == expected_witnesses
expected_witnesses.each do |name|
  errors << "Missing witness profile for #{name}" unless speakers.key?(name)
end

paper_38 = talks_by_id["38"]
errors << "New Issa Kansaye paper 38 is missing" unless paper_38 && Array(paper_38["speakers"]) == ["Issa Kansaye"]
paper_38_slot = scheduled.find { |slot| paper_38 && slot["name"] == paper_38["name"] }
errors << "Paper 38 must be online on Thursday at 09:30" unless paper_38_slot && paper_38_slot["date"] == "2026-09-10" && paper_38_slot["room"] == "En ligne" && paper_38_slot["time_start"] == "09:30" && paper_38_slot["time_end"] == "09:40"

{"39" => ["En ligne", "10:55"], "40" => ["En ligne", "11:05"], "41" => ["Salle de conférence de l’ISH", "11:15"]}.each do |paper_id, (room, start_time)|
  talk = talks_by_id[paper_id]
  errors << "New paper #{paper_id} is missing" unless talk
  slot = scheduled.find { |candidate| talk && candidate["name"] == talk["name"] }
  errors << "Paper #{paper_id} has the wrong Thursday placement" unless slot && slot["date"] == "2026-09-10" && slot["room"] == room && slot["time_start"] == start_time
end

paper_42 = talks_by_id["42"]
paper_42_slot = scheduled.find { |slot| paper_42 && slot["name"] == paper_42["name"] }
errors << "New paper 42 is missing" unless paper_42 && Array(paper_42["speakers"]) == ["Amadou Diabaté"]
errors << "Paper 42 must be on-site on Wednesday at 12:20" unless paper_42_slot && paper_42_slot["date"] == "2026-09-09" && paper_42_slot["room"] == "Salle de conférence de l’ISH" && paper_42_slot["time_start"] == "12:20" && paper_42_slot["time_end"] == "12:30"

errors << "Poster paper 40 is not converted to oral" unless talks_by_id.dig("40", "scheduled_format") == "Orale"

expected_paper_30_speakers = ["Dabiré Der", "Sheila Médina KARAMBIRI", "Tionyélé FAYAMA", "TOE Patrice", "MAIGA Alkassoum"]
errors << "Paper 30 is missing one or more confirmed co-authors" unless talks_by_id.dig("30", "speakers") == expected_paper_30_speakers
errors << "Missing speaker profile for Sheila Médina KARAMBIRI" unless speakers.key?("Sheila Médina KARAMBIRI")

corrected_program_labels = [
  "Mots de bienvenue du directeur général de l’ISH",
  "Témoignages sur NIANGUIRY KANTÉ",
  "Pause déjeuner",
  "LE ŊIAGUWANTULO, UNE MANIFESTATION RELIGIEUSE FÉMININE DE NARÉNA (MALI) : MODALITÉS ET DYNAMIQUES SOCIOCULTURELLES",
  "Photo de famille",
  "Remerciements et clôture des travaux"
]
corrected_program_labels.each do |corrected_name|
  errors << "Missing corrected program label: #{corrected_name}" unless scheduled.any? { |slot| slot["name"] == corrected_name }
end

%w[29].each do |paper_id|
  errors << "Former poster #{paper_id} is not scheduled as oral" unless talks_by_id.dig(paper_id, "scheduled_format") == "Orale"
end

keynote = talks_by_id["13"]
errors << "Paper 13 is not categorized as keynote/opening" unless Array(keynote["categories"]).include?("Ouverture")
keynote_source = File.read(talk_files.find { |path| front_matter(path)["paper_id"].to_s == "13" }, encoding: "UTF-8")
errors << "Paper 13 missing keynote credentials" unless keynote_source.include?("directeur de publication de la revue *Psychologie Clinique*") && keynote_source.include?("RASP")

if errors.any?
  warn errors.join("\n")
  exit 1
end

puts "Validated #{talk_files.length} talks and #{speaker_files.length} speakers."
