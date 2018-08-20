# frozen_string_literal: true

# Allows each attachment to have it's own policy
# Example:
# has_one_attached :avatar -> AvatarPolicy / avatar_policy.rb
module ActiveStorage
  class Attached
    def policy_class
      "#{name}_policy".classify.safe_constantize
    end
  end
end
