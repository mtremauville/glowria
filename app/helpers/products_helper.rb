module ProductsHelper
  # Returns a URL string for the product's display image (Active Storage or external URL).
  def product_image_url(product)
    img = product.display_image
    return nil unless img
    img.is_a?(String) ? img : url_for(img)
  end

  # Small thumbnail for the product list chip (image or placeholder icon).
  def product_chip_thumb_html(product)
    thumb = product_image_url(product)
    if thumb
      image_tag(thumb, alt: product.name, class: "product-chip__img")
    else
      content_tag(:div, class: "product-chip__placeholder") do
        content_tag(:i, nil, class: "fa-solid fa-bottle-droplet")
      end
    end
  end

  # Thumbnail block for the show page (image + delete button or placeholder).
  def product_thumb_html(product)
    if product.display_image
      thumb = product_image_url(product)
      html  = image_tag(thumb, alt: product.name, class: "prod-header__img")
      if product.photo.attached?
        html += button_to(purge_photo_product_path(product), method: :delete,
                          data: { turbo_confirm: "Supprimer la photo de ce produit ?" },
                          class: "prod-header__photo-delete") do
          content_tag(:i, nil, class: "fa-solid fa-trash")
        end
      end
      html
    else
      content_tag(:i, nil, class: "fa-solid fa-bottle-droplet prod-header__icon")
    end
  end

  # Current photo block for the edit form (avoids conflicting linter rules).
  def product_current_photo_html(product)
    thumb = product_image_url(product)
    return nil unless thumb

    content_tag(:div, class: "edit-current-photo") do
      image_tag(thumb, alt: product.name, class: "edit-current-photo__img") +
        content_tag(:p, "Photo actuelle — prends-en une nouvelle pour la remplacer",
                    class: "edit-current-photo__label")
    end
  end
end
