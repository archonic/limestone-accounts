# frozen_string_literal: true

module IconHelper
  SIZES = { xs: 12, sm: 16, md: 26, lg: 44, xl: 144, xxl: 230 }.freeze

  def avatar(resource, size = :sm, options = {})
    width = SIZES[size]
    img_or_text = resource.avatar.attached? ? "img" : "text"
    image_url = avatar_url(resource, width)
    additional_classes = options[:class] || ""
    image = image_tag(image_url) if image_url.present?
    avatar_icon(
      [image, resource.try(:name).try(:initials)].join,
      style: size.to_s,
      class: "avatar-#{img_or_text} " + additional_classes,
      alt: resource.name
    )
  end

  def avatar_url(resource, width)
    if resource.avatar.attached?
      size_str = "#{width}x#{width}"
      url_for( resource.avatar.variant(resize: size_str) )
    elsif resource.respond_to? :email
      hash = Digest::MD5.hexdigest(resource.email.try(:downcase) || "noemail")
      "https://secure.gravatar.com/avatar/#{hash}?d=blank&s=#{width}"
    end
  end

  # https://fontawesome.com/v4.7.0/icons/
  def icon(reference, size = :sm, options = {})
    options[:style] = "font-size: #{SIZES[size]}px"
    options[:class] = "fa fa-#{reference} #{options[:class]}"
    content_tag(:i, nil, options)
  end

  private

    def avatar_icon(content, options = {})
      style = options.delete(:style) || "md"
      # rubocop:disable Rails/OutputSafety
      content_tag(
        :span,
        raw(content),
        options.merge!(
          class: ["avatar-icon rounded", style, options[:class]].compact.join(" ")
        )
      )
      # rubocop:enable Rails/OutputSafety
    end
end
