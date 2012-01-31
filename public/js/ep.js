(function($) {
  //polling parameters:
  var interval = 5*1000; //5 seconds
  var max_tries = 12*15; //15 minutes
  var counter = 0;
  var interval_id = null;
  var last_inbox_hash = null;

  var generate_email = function() {
    var domain='eyepaste.com';
    var string_length = 5;

    var chars = "0123456789abcdefghiklmnopqrstuvwxyz";
    var random_string = '';
    for (var i=0; i < string_length; i++) {
      var rnum = Math.floor(Math.random() * chars.length);
      random_string += chars.substring(rnum, rnum+1);
    }

    return random_string + '@' + domain;
  };

  var email = generate_email();

  var inbox_link = 'http://eyepaste.com/inbox/' + escape(email);
  var rss_link = inbox_link + '.rss'
  var poll_link = inbox_link + '.json'

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
      $.get(poll_link, {}, function(data) {
        if (last_inbox_hash && data.inbox_hash != last_inbox_hash) {
          //good to go, redirect us:
          stop_polling();
          window.location = inbox_link
        }
      }, 'json');

    } else {
      // we have reached max tries:
      stop_polling();
      $('checkingemail').toggle();
      $('notcheckingemail').toggle();
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
