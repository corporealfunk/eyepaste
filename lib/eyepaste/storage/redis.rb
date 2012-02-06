require 'json'

module Eyepaste
  module Storage
    class Redis

      def initialize(redis)
        @redis = redis
      end

      def append_email(inbox, email)
        result = @redis.mapped_hmset(_email_key(inbox), _storage_hash(email.attributes))
        return true if result == 'OK'
      end

      def get_inbox(inbox)
        emails = []
        inbox_keys = @redis.keys("email:#{inbox}_*")
        inbox_keys.sort.each do |key|
          from_storage = @redis.mapped_hmget(key, *_storage_hash_keys(Eyepaste::Email.new.attributes.keys))
          emails << Eyepaste::Email.new(from_storage)
        end
        emails
      end

      def count_emails
        @redis.keys("email:*").count
      end

      # super not efficient
      def expire_emails_before(epoch)
        all_keys = @redis.keys('email:*')
        # examine each hash to see if it is before our epoch
        to_del = []
        all_keys.each do |key|
          key_epoch = @redis.hmget(key, :created_at).first.to_i
          to_del << key if key_epoch < epoch.to_i
        end
        @redis.del(*to_del)
      end

      def delete_all
        @redis.flushdb
      end

      private
      def _email_key(inbox)
        "email:#{inbox}_#{Time.now.utc.to_f}"
      end

      def _storage_hash(email_attributes)
        email_attributes.merge({
          :created_at => Time.now.utc.to_i.to_s
        })
      end

      def _storage_hash_keys(attribute_keys)
        attribute_keys << :created_at
      end

    end
  end
end
