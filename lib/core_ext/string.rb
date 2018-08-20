# frozen_string_literal: true

class String
  def initials(len = 3)
    return nil if blank?
    split.map(&:first)[0..(len - 1)].join("").upcase
  end
end
