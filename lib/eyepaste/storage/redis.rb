module Eyepaste
  module Storage
    # TODO: passwords, users, databases
    class Redis

      def initialize(redis)
        @redis = redis
      end


      def append_email(inbox, email)
        true
      end

      def get_inbox(inbox)
        [Eyepaste::Email.new]
      end

    end
  end
end
