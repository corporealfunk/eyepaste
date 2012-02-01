require File.dirname(__FILE__) + '/../lib/eyepaste/email.rb'

path_to_emails = File.dirname(__FILE__) + '/emails'
EMAILS = {
  :plain_text => "#{path_to_emails}/plain_text.eml",
  :multi_part => "#{path_to_emails}/multi_part.eml"
}
