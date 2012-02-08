module Eyepaste
  class Email
    attr_accessor :raw_headers, :decoded_body, :to, :from, :date, :subject


    def initialize(options = {})
      @raw_headers = options[:raw_headers] || options['raw_headers']
      @decoded_body = options[:decoded_body] || options['decoded_body']
      @to = options[:to] || options['to'] || nil
      @to = if @to
              [@to] if !@to.kind_of?(Array)
            else
              []
            end
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
      email.from = mail.header[:from].to_s
      email.date = mail.header[:date].to_s
      email.subject = mail.header[:subject].to_s

      if mail[:to]
        mail[:to].addresses.each do |address|
          email.to << address if address
        end
      end

      # see if we have charsets in our parts to
      # use for encoding the body later:
      charsets = []
      mail.parts.each { |part| charsets << part.charset } if mail.multipart?
      charsets.uniq!

      # NOTE: the following charset conversions seem to be due to the fact that
      # the mail gem is not very smart re:charsets. we have to detect and
      # encode on our own if we can

      # if our email is in a charset, convert the decoded body to that
      # else, use the charsets as computed above from the parts
      if mail.charset && !mail.charset.empty?
        email.decoded_body = email.decoded_body.encode('UTF-8', mail.charset)
      else
        # no mail.charset present, do we have a charsets Array of 1?
        email.decoded_body = email.decoded_body.encode('UTF-8', charsets[0]) if charsets.length == 1
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


    def attributes(opts = {})
      opts[:flatten] ||= false

      { :raw_headers => @raw_headers,
        :decoded_body => @decoded_body,
        :to => (opts[:flatten]) ? @to.join(', ') : @to,
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
