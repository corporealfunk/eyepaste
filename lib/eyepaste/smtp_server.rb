module Eyepaste
  class SmtpServer < EM::Protocols::SmtpServer
    def initialize(*args)
      super
      @parms[:chunksize] = 1024
      @storage = Eyepaste::Storage::factory
    end

    def receive_recipient(recipient)
      # accept all email
      true
    end

    def receive_data_chunk(data)
      @email_content << data
      true
    end

    def receive_message
      begin
        email = Eyepaste::Email.parse_raw_email(@email_content)
        @storage.append_email(email.to, email)
      rescue Exception => e
        # never let us die, only log exceptions:
        LOGGER.warn "#{e.class}: #{e.message}:\n#{content}"
      end

      true
    end
  end
end
