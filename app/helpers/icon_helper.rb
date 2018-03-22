module IconHelper
  AVATAR_SIZES = {xs: 9, sm: 18, md: 36, lg: 72, xl: 144}.freeze

  def avatar(user, size = :sm, options = {})
    width = AVATAR_SIZES[size]
    resize_str = "#{width}x#{width}"
    img_or_text = user.avatar.attached? ? 'img' : 'text'
    image_url = if user.avatar.attached?
      user.avatar.variant(resize: resize_str)
    else
      hash = Digest::MD5.hexdigest(user.email.try(:downcase) || 'noemail')
      "https://secure.gravatar.com/avatar/#{hash}?d=blank&s=#{width}"
    end
    additional_classes = options[:class] || ''
    circular_icon(
      image_tag(
        image_url,
        class: 'rounded-circle'
      ) + user.try(:full_name).try(:initials),
      style: size.to_s,
      class: "avatar-#{img_or_text} " + additional_classes,
      alt: user.full_name
    )
  end

  def circular_icon(content, options = {})
    style = options.delete(:style) || 'md'
    content_tag(
      :span,
      content,
      options.merge!(
        class: ['circular-icon', style, options[:class]].compact.join(' ')
      )
    )
  end

  # https://fontawesome.com/v4.7.0/icons/
  def icon(reference, size = :sm, options = {})
    options.merge!(style: "font-size: #{AVATAR_SIZES[size]}px")
    options.merge!(class: "fa fa-#{reference} #{options[:class]}")
    content_tag(:i, nil, options)
  end
end
