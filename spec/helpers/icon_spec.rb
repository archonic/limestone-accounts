# frozen_string_literal: true

require "rails_helper"

describe IconHelper do
  let(:user) { create(:user) }

  describe "avatar" do
    it "defaults to small" do
      expect(avatar(user)).to match ";s=#{IconHelper::SIZES[:sm]}"
    end

    it "returns avatar" do
      expect(avatar(user)).to match "avatar-icon rounded sm avatar-text"
    end

    it "has text backup" do
      expect(avatar(user)).to match user.full_name.initials
    end
  end

  describe 'icon' do
    it 'defaults to small' do
      expect(icon(:beer)).to match "font-size: #{IconHelper::SIZES[:sm]}px"
    end

    it 'returns a font awesome icon' do
      expect(icon(:beer)).to match "fa fa-beer"
    end
  end
end
