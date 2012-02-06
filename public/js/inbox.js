(function($) {
  $(document).ready(function() {
    $('a.extended_headers').click(function(e) {
      e.preventDefault();
      var $link = $(e.target);
      $(e.target).closest('.emailmessage').find('.fullheaders').toggle('slow', function() {
        if ($(this).is(':visible')) {
          $link.text('hide full headers');
        } else {
          $link.text('view full headers');
        }
      });
    });
  });
})(jQuery);
