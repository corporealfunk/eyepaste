require 'json'

module Eyepaste
  module Storage
    class Redis
      attr_reader :accepted_domains

      def initialize(redis)
        @redis = redis
        @accepted_domains = []
      end

      def accepted_domains=(domain)
        @accepted_domains = (domain.kind_of?(Array)) ? domain : [domain]
      end

      def append_email(inbox, email)
        inbox = [inbox] if !inbox.kind_of?(Array)

        inbox.reject! { |address| address.nil? || address.empty? }
        inbox.reject! do |address|
          matches = address.match(/@(.*)$/)
          ret = (matches && matches[1]) ? !@accepted_domains.member?(matches[1]) : true
          ret
        end
        return false if inbox.count == 0

        ret = true
        inbox.each do |address|
          ret = false if @redis.mapped_hmset(_email_key(address), _storage_hash(email.attributes(:flatten => true))) != 'OK'

        end
        ret
      end

      def get_inbox(inbox, options = {})
        merged_options = {
          sort: :asc,
          limit: 0,
          start: 1
        }.merge(options)

        start_i = [0, merged_options[:start] - 1].max
        limit = [0, merged_options[:limit]].max

        emails = []
        inbox_keys = @redis.keys("email:#{inbox}_*")

        inbox_keys.sort!
        inbox_keys.reverse! if merged_options[:sort] == :desc

        end_i = (limit == 0 ? inbox_keys.length: start_i + limit) - 1
        end_i = [inbox_keys.length - 1, end_i].min

        inbox_keys = inbox_keys[(start_i..end_i)]

        inbox_keys.each do |key|
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
        keys_to_del = []
        all_keys.each do |key|
          key_epoch = @redis.hmget(key, :created_at).first.to_i
          keys_to_del << key if key_epoch < epoch.to_i
        end
        @redis.del(*keys_to_del) if keys_to_del.length > 0
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
