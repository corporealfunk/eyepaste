(function($) {
  //polling parameters:
  var interval = 5*1000; //5 seconds
  var max_tries = 12*15; //15 minutes
  var counter = 0;
  var interval_id = null;
  var last_inbox_count = 0;
  var domain=$('#emailbox').attr('data-domain');
  var email_domain=$('#emailbox').attr('data-email-domain');
  var port=$('#emailbox').attr('data-port');
  port = (port == '80' || port == '443') ? '' : ':' + port;

  var generate_email = function(email_domain) {
    var string_length = 5;

    var chars = "0123456789abcdefghiklmnopqrstuvwxyz";
    var random_string = '';
    for (var i=0; i < string_length; i++) {
      var rnum = Math.floor(Math.random() * chars.length);
      random_string += chars.substring(rnum, rnum+1);
    }

    return random_string + '@' + email_domain;
  };

  var email = generate_email(email_domain);

  var inbox_link = window.location.protocol + '//' + domain + port + '/inbox/' + escape(email);
  var rss_link = inbox_link + '.rss'
  var poll_link = '/inbox/' + escape(email) + '.json'

  $(document).ready(function() {
   $('#emailbox h1.email').text(email);
   $('#emailbox a.inbox').text(inbox_link);
   $('#emailbox a.rss').text(rss_link);

   $('a.inbox').attr('href', inbox_link);
   $('a.rss').attr('href', rss_link);
   start_polling();
  });

  var poll = function() {
    counter++;
    if (counter < max_tries) {
      $.get(poll_link, {}, function(inbox) {
        if (inbox.count != last_inbox_count) {
          //good to go, redirect us:
          stop_polling();
          window.location = inbox_link
        } else {
          last_inbox_count = inbox.count;
        }
      }, 'json');

    } else {
      // we have reached max tries:
      stop_polling();
      $('#checkingemail').toggle();
      $('#notcheckingemail').toggle();
      alert("We haven't received any emails to this temporary address in a while, so we're just gonna stop checking automatically. The email address " + email + " is still good, though... just use your permalink or RSS feed to check for mail there.");
    }
  }

  var start_polling = function() {
    interval_id = setInterval(poll, interval);
  }

  var stop_polling = function() {
    clearInterval(interval_id);
  }
})(jQuery);
