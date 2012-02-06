module Eyepaste
  class Email
    attr_accessor :raw_headers, :decoded_body, :parts, :to, :from, :date, :subject


    def initialize(options = {})
      @raw_headers = options[:raw_headers] || options['raw_headers']
      @decoded_body = options[:decoded_body] || options['decoded_body']
      @parts = options[:parts] || options['parts'] || {}
      @to = options[:to] || options['to'] || nil
      @from = options[:from] || options['from'] || nil
      @date = options[:date] || options['date'] || nil
      @subject = options[:subject] || options['subject'] || nil
    end


    # parses a raw MIME encoded email into
    # the attributes
    def self.parse_raw_email(content)
      email = Eyepaste::Email.new
      mail = Mail.new(content)
      email.raw_headers = mail.header.raw_source
      email.decoded_body = mail.body.decoded
      email.to = mail.header[:to].to_s
      email.from = mail.header[:from].to_s
      email.date = mail.header[:date].to_s
      email.subject = mail.header[:subject].to_s

      # if the to filed contains something between <> pull that out:
      if email.to.match(/<(.+?)>/)
        to_parts = email.to.match(/<(.+?)>/)
        if to_parts.length == 2
          email.to = to_parts[1]
        end
      end

      # if multipart, set our parts hash so that the
      # keys are the content types and the values are the
      # decoded bodies
      if mail.multipart?
        keys = mail.parts.map { |part| part.content_type }
        vals = mail.parts.map { |part| part.body.decoded }
        keys.zip(vals).each do |part|
          email.parts[part[0]] = part[1].force_encoding Encoding::UTF_8
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


    def attributes
      { :raw_headers => @raw_headers,
        :decoded_body => @decoded_body,
        :parts => @parts,
        :to => @to,
        :from => @from,
        :date => @date,
        :subject => @subject
      }
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
