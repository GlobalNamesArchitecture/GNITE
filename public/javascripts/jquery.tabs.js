$(function() {
  $('.ui-tabs-nav a').click(function() {
    if ($(this).attr('id') === "all-tabs") {
      $('#reference-trees').parent().toggleClass('ui-tabs-selected ui-state-active');
    } else {
      var ele = $(this).attr('href');

      $(this).closest('.ui-tabs').find('.ui-tabs-panel').addClass('ui-tabs-hide');
      $(this).closest('.ui-tabs').find('.ui-tabs-nav li').removeClass('ui-tabs-selected ui-state-active');

      $(this).closest('.ui-tabs').find(ele).removeClass('ui-tabs-hide');
      $(this).parent().addClass('ui-tabs-selected ui-state-active');
    }

    return false;
  });

  $('body').click(function(event) {
    if ($(event.target).parent('.ui-tabs').length == 0 || event.target.nodeName != 'A') {
      $('.ui-tabs').find('.ui-tabs-selected').each(function() {
        if($(this).children("ul").length > 0) { $(this).removeClass('ui-tabs-selected ui-state-active'); }
      });
    }
  });

});
