$(function() {
  $('#tabs').tabs({
    select: function(event, ui) {
      if ($(ui.tab).text() == 'All working trees') {
        $(ui.tab).parent().addClass('ui-tabs-selected ui-state-active');

        return false;
      }
    }
  });

  $('#import a').trigger('click');

  $('body').click(function(event) {
    if ($(event.target).parent('#tabs').length == 0 || event.target.nodeName != 'A') {
      $('#all-tabs').parent().removeClass('ui-tabs-selected ui-state-active');
    }
  });
});
