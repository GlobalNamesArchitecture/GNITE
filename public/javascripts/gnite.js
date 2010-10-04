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





/*
 * Reference Trees
 */
var
GNITE = GNITE || {};
GNITE.ReferenceTree = GNITE.ReferenceTree || {};

// TODO: Merge with MasterTree options.
GNITE.ReferenceTree.options = {
  'json_data' : {
    'ajax' : {
      'data' : function(node) {
        if (node.attr) {
          return { 'parent_id' : node.attr('id') };
        } else {
          return {};
        }
      }
    }
  },

  'crrm' : {
    'move' : {
      'check_move'  : function() { return false },
      'always_copy' : 'multitree'
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm']
};

$(function() {
  // TODO: Clean up.
  $('.reference-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var tree     = self.parents('.reference-tree');
    var metadata = tree.find('.node-metadata');
    var tree_id  = tree.attr('id').split('_')[2];
    var node_id  = self.parent('li').attr('id');

    metadata.spinner();

    $.getJSON('/reference_trees/' + tree_id + '/nodes/' + node_id, function(data) {
      var rank             = $.trim(data.rank);
      var synonyms         = data.synonyms;
      var vernacular_names = data.vernacular_names;

      metadata.find('.metadata-section ul').empty();

      if (synonyms.length == 0) {
        metadata.find('.metadata-synonyms ul').append('<li>None</li>');
      } else {
        $.each(synonyms, function(index, synonym) {
          metadata.find('.metadata-synonyms ul').append('<li>' + synonym + '</li>');
        });
      }

      if (vernacular_names.length == 0) {
        metadata.find('.metadata-vernacular-names ul').append('<li>None</li>');
      } else {
        $.each(vernacular_names, function(index, vernacular_name) {
          metadata.find('.metadata-vernacular-names ul').append('<li>' + vernacular_name + '</li>');
        });
      }

      if (rank == '') {
        metadata.find('.metadata-rank ul').append('<li>None</li>');
      } else {
        metadata.find('.metadata-rank ul').append('<li>' + rank + '</li>');
      }

      var wrapper = tree.find('.reference_tree_container > div');

      metadata.show();
      wrapper.css('bottom', metadata.height());

      var nodePosition  = self[0].offsetTop - wrapper[0].scrollTop;
      var visibleHeight = wrapper.height();

      if (nodePosition >= visibleHeight) {
        wrapper[0].scrollTop += nodePosition - visibleHeight + 36;
      }

      metadata.unspinner();
    });
  });

  if ($('#working-trees li').length == 0) {
    $('#tab-titles li:first-child').hide();
  }
});




/*
 * Search
 */
$(function() {
  $('#search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var
        container = self.parents('.gnaclr-search').first();
        container.spinner();

        $.get('/search', { 'search_term' : term }, function(results) {
          container.unspinner();

          $('#new-tab .tree-background').html(results);
        });
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        $(this).blur();
      }
    });
});
