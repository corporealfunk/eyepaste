require 'json'

module Eyepaste
  module Storage
    # TODO: passwords, users, databases
    class Redis

      def initialize(redis)
        @redis = redis
      end

      def append_email(inbox, email)
        attributes = email.attributes
        attributes[:created_at] = Time.now.utc.to_i
        @redis.rpush(inbox, attributes.to_json)
      end

      def get_inbox(inbox)
        len = @redis.llen(inbox)
        emails = []
        items = @redis.lrange(inbox, 0, len - 1)
        items.each do |item|
          emails << Eyepaste::Email.new(JSON.parse(item))
        end
        emails
      end

    end
  end
end
