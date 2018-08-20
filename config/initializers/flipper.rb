# frozen_string_literal: true

require "flipper"
require "flipper/adapters/redis"

# FEATURES:
# public_registration

Flipper.configure do |config|
  config.default do
    flipper_url = "#{ENV['REDIS_BASE_URL']}/flipper"
    client = Redis.new(url: flipper_url)
    adapter = Flipper::Adapters::Redis.new(client)
    Flipper.new adapter
  end

  # TODO reinstate after roles are sorted
  # Register each role as a group
  # Flipper.register(:admin) do |actor|
  #   actor.respond_to?(:admin?) && actor.admin?
  # end
  #
  # Flipper.register(:basic) do |actor|
  #   actor.respond_to?(:basic?) && actor.basic?
  # end
  #
  # Flipper.register(:pro) do |actor|
  #   actor.respond_to?(:pro?) && actor.pro?
  # end
  #
  # Flipper.register(:removed) do |actor|
  #   actor.respond_to?(:removed?) && actor.removed?
  # end
end
