/*
 * Import a Flat List
 */
$(function() {
  $('#import-roots-button').live('click', function() {
    var data = JSON.stringify({
      'nodes_list'     : $('#import-roots').val().split("\n"),
      'reference_tree' : {
        'title'          : 'List',
        'master_tree_id' : $('#tree-container').attr('data-database-id')
      }
    });

    $.ajax({
      url         : $(this).parent('form').attr('action') + '.json',
      type        : 'POST',
      data        : data,
      contentType : 'application/json',
      success     : function() {
        // TODO: Don't do this.
        // TODO: Actually render and show the newly created reference tree.
        location.reload();
      }
    });

    return false;
  });
});
