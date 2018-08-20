# frozen_string_literal: true

class CanAccessAdmin
  def self.matches?(request)
    current_user = request.env["warden"].user
    current_user.present? && current_user.respond_to?(:super_admin?) && current_user.super_admin?
  end
end

class Subdomain
  def self.matches?(request)
    case request.subdomains.try(:first)
    when nil, ""
      false
    else
      true
    end
  end
end

class NoSubdomain
  def self.matches?(request)
    request.subdomain.blank?
  end
end
