require File.dirname(__FILE__) + '/../lib/eyepaste/email.rb'

path_to_emails = File.dirname(__FILE__) + '/emails'
EMAILS = {
  :plain_text => "#{path_to_emails}/plain_text.eml",
  :multi_part => "#{path_to_emails}/multi_part.eml",
  :encoding_problem => "#{path_to_emails}/encoding_problem.eml",
  :xd3_conversion => "#{path_to_emails}/xd3_conversion.eml",
  :multiple_tos => "#{path_to_emails}/multiple_tos.eml"
}
