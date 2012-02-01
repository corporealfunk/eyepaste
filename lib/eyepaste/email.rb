module Eyepaste
  class Email
    attr_accessor :raw_headers, :decoded_body, :parts


    def initialize
      @parts = {}
    end


    # parses a raw MIME encoded email into
    # the attributes
    def self.parse_raw_email(content)
      email = Eyepaste::Email.new
      mail = Mail.new(content)
      email.raw_headers = mail.header.raw_source
      email.decoded_body = mail.body.decoded

      # if multipart, set our parts hash so that the
      # keys are the content types and the values are the
      # decoded bodies
      if mail.multipart?
        keys = mail.parts.map { |part| part.content_type }
        vals = mail.parts.map { |part| part.body.decoded }
        keys.zip(vals).each do |part|
          email.parts[part[0]] = part[1]
        end
      end

      email
    end


    # finds and returns the plain text part if it exists
    def plain_text
      _search_parts_keys(/plain/i)
    end


    # finds and returns the html part if it exists
    def html
      _search_parts_keys(/html/i)
    end


    private
    def _search_parts_keys(matcher)
      parts_key = nil
      @parts.keys.each do |key|
        parts_key = key if key.match(matcher)
      end

      parts[parts_key] if parts_key
    end

  end
end
