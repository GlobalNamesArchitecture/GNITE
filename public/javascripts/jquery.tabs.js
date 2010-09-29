$(function() {
  $('#tab-titles a').live('click', function() {
    if ($(this).attr('id') == 'all-tabs') {
      $('#working-trees').parent().toggleClass('ui-tabs-selected ui-state-active');
    } else {
      var id = $(this).attr('href');

      $('#tabs > .ui-tabs-panel:visible').addClass('ui-tabs-hide');
      $('.ui-tabs-selected.ui-state-active').removeClass('ui-tabs-selected ui-state-active');

      $(id).removeClass('ui-tabs-hide');
      $(this).parent().addClass('ui-tabs-selected ui-state-active');
    }

    return false;
  });

  $('body').click(function(event) {
    if ($(event.target).parent('#tabs').length == 0 || event.target.nodeName != 'A') {
      $('#all-tabs').parent().removeClass('ui-tabs-selected ui-state-active');
    }
  });
});
