# frozen_string_literal: true

require "yaml"
require "date"

program = YAML.safe_load(File.read("_data/program.yml", encoding: "UTF-8"), permitted_classes: [Date], aliases: true)
page = File.read("program/index.md", encoding: "UTF-8")

abort "Program must display a provisional-program warning." unless page.include?("Programme provisoire") && page.include?("susceptible de modifications") && page.include?("vendredi 4 septembre 2026")
abort "Provisional-program warning must be red and dismissible." unless page.include?("alert alert-danger alert-dismissible")
abort "Program must state the 10-minute speaking limit." unless page.include?("<strong>10 minutes</strong>")
abort "Program must explain that discussion duration depends on the session." unless page.include?("durée") && page.include?("adaptée au nombre de communications") && page.include?("discussion collective")
abort "Unnecessary explanation about hidden Discussion blocks remains." if page.include?("aucun bloc « Discussion » séparé")
abort "Original theme room grid structure is missing." unless program["days"].all? { |day| day["rooms"].is_a?(Array) }
abort "A custom program layout still replaces the theme grid." if File.exist?("_layouts/program.html")

slots = program["days"].flat_map { |day| day["rooms"].flat_map { |room| room["talks"] || [] } }
discussion_name = "Discussion collective et questions"
discussions = slots.select { |slot| slot["name"] == discussion_name }
abort "Six collective discussion blocks must appear." unless discussions.length == 6

duration = lambda do |slot|
  start_hour, start_minute = slot["time_start"].split(":").map(&:to_i)
  end_hour, end_minute = slot["time_end"].split(":").map(&:to_i)
  (end_hour * 60 + end_minute) - (start_hour * 60 + start_minute)
end

expected_discussion_durations = [15, 15, 15, 15, 15, 15]
actual_discussion_durations = discussions.map(&duration).sort
abort "Collective discussion durations are incorrect." unless actual_discussion_durations == expected_discussion_durations

cmt_names = Dir["_talks/cmt-*.md"].filter_map do |path|
  data = YAML.safe_load(File.read(path, encoding: "UTF-8").split(/^---\s*$\r?\n/)[1], aliases: true)
  data["name"] if Array(data["categories"]).include?("Communications")
end
scheduled_cmt_slots = slots.select { |slot| cmt_names.include?(slot["name"]) }
abort "Every CMT talk must be scheduled for exactly 10 minutes." unless scheduled_cmt_slots.all? { |slot| duration.call(slot) == 10 }
abort "Session labels are not embedded in the grid data." unless slots.count { |slot| slot["session"] } == 6
abort "Session moderator labels are missing." unless slots.select { |slot| slot["session"] }.all? { |slot| slot["moderator"] }
expected_moderators = ["Macire KANTE", "Sekou CAMARA", "Amadou DIABATE", "Silamakan KANTE", "Soumaila Oulalé", "Mahamadou KANTE"]
actual_moderators = program["days"].flat_map do |day|
  day["rooms"].flat_map { |room| room["talks"].select { |slot| slot["session"] }.map { |slot| [day["date"].to_s, slot] } }
end.sort_by { |date, slot| [date, slot["time_start"]] }.map { |_date, slot| slot["moderator"] }
abort "Confirmed moderators are assigned to the wrong sessions." unless actual_moderators == expected_moderators

day1 = program["days"].find { |day| day["date"].to_s == "2026-09-09" }
day2 = program["days"].find { |day| day["date"].to_s == "2026-09-10" }
day1_slots = day1["rooms"].flat_map { |room| room["talks"].map { |talk| talk.merge("room" => room["name"]) } }
day2_slots = day2["rooms"].flat_map { |room| room["talks"].map { |talk| talk.merge("room" => room["name"]) } }

abort "Wednesday lunch must begin at 13:15." unless day1_slots.any? { |slot| slot["name"] == "Pause déjeuner" && slot["time_start"] == "13:15" }
abort "Wednesday must finish at 15:45." unless day1_slots.map { |slot| slot["time_end"] }.max == "15:45"
abort "Thursday lunch must run from 12:00 to 14:00." unless day2_slots.any? { |slot| slot["name"] == "Pause déjeuner" && slot["time_start"] == "12:00" && slot["time_end"] == "14:00" }
new_ids_titles = ["Solidarités héritées aux ressources de gouvernance locale", "Gestion des conflits dans la production de coton biologique", "La gestion des conflits par le Sanangouya"]
new_presentation_times = ["11:15", "11:25", "11:35"]
new_presentations = day2_slots.select { |slot| new_ids_titles.any? { |title| slot["name"].start_with?(title) } }
abort "The three new presentations must precede the collective discussion." unless new_presentations.map { |slot| slot["time_start"] }.sort == new_presentation_times
abort "The pre-lunch discussion must run from 11:45 to 12:00." unless day2_slots.any? { |slot| slot["name"] == discussion_name && slot["time_start"] == "11:45" && slot["time_end"] == "12:00" }
abort "Scientific synthesis must be removed from the schedule." if day2_slots.any? { |slot| slot["name"] == "Synthèse scientifique des deux journées" }
abort "Thursday must finish at 15:30." unless day2_slots.map { |slot| slot["time_end"] }.max == "15:30"

puts "Ten-minute grid with six explicit collective discussions is present."
