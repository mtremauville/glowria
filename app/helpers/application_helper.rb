# app/helpers/application_helper.rb
module ApplicationHelper
  def severity_badge(severity)
    config = {
      "high"   => ["🔴", "Élevé",   "danger"],
      "medium" => ["🟡", "Modéré",  "warning"],
      "low"    => ["🟢", "Faible",  "success"]
    }
    icon, label, color = config.fetch(severity, ["⚪", severity, "secondary"])
    content_tag(:span, "#{icon} #{label}", class: "badge bg-#{color}")
  end

  def slot_badge(slot)
    config = {
      "morning" => ["☀️", "Matin",  "warning"],
      "evening" => ["🌙", "Soir",   "primary"],
      "both"    => ["🔄", "AM/PM",  "secondary"]
    }
    icon, label, color = config.fetch(slot, ["•", slot, "secondary"])
    content_tag(:span, "#{icon} #{label}", class: "badge bg-#{color} bg-opacity-10 text-#{color}-emphasis")
  end
end
