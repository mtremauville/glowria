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

  # Couleur d'un tag molécule selon la fonction de l'ingrédient
  MOLECULE_FUNCTION_COLORS = {
    /hydrat|humect|moistur/i          => "mol--hydrating",
    /antioxyd|vitamine\s*[ce]|vitamin/i => "mol--antioxidant",
    /anti.?[aâ]ge|rétinol|retinol|peptide|collag/i => "mol--antiage",
    /exfoli|aha|bha|acide\s*glycol|acide\s*salicyl/i => "mol--exfoliant",
    /apais|calm|sooth|cicatri/i       => "mol--soothing",
    /spf|filtrant|photoprotect/i      => "mol--spf",
    /conserv|preserv|paraben/i        => "mol--preservative",
    /émulsif|emulsif|textur|stabilisant/i => "mol--emulsifier",
    /parfum|fragrance|essential\s*oil/i   => "mol--fragrance"
  }.freeze

  MOLECULE_PALETTE = %w[
    mol--hydrating mol--antioxidant mol--antiage mol--exfoliant
    mol--soothing mol--spf mol--emulsifier mol--fragrance
  ].freeze

  def molecule_color_from_function(function_text)
    return nil if function_text.blank?
    MOLECULE_FUNCTION_COLORS.each { |pattern, css| return css if function_text.match?(pattern) }
    nil
  end

  # Couleur déterministe par nom (pour les routines où on n'a que le nom)
  def molecule_color_from_name(name)
    MOLECULE_PALETTE[name.to_s.sum % MOLECULE_PALETTE.size]
  end

  # Avatar HTML for the navbar profile button (avoids conflicting linter rules)
  def navbar_avatar_html(user)
    if user.avatar.attached?
      image_tag user.avatar.variant(resize_to_fill: [34, 34]),
                class: "navbar-avatar-img", alt: ""
    elsif user.display_name.present?
      content_tag(:span, user.display_name[0].upcase, class: "navbar-avatar-initials")
    else
      content_tag(:i, nil, class: "fa-solid fa-circle-user")
    end
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
