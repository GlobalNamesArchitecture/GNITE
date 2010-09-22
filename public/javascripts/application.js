$(document).ready(function() {
  $('#browse-gnaclr-button').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('.ajax-load-new-tab').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('.gnaclr_classification_show').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('#import-gnaclr-button').live('click', function() {
    $('#gnaclr-description').append('<div class="spinner" />');

    var checkedRadioButton = $("#tree-revisions form input:checked");
    $.post('/gnaclr_imports', { master_tree_id : $('#tree-container').attr('data-database-id'), title : $('#gnaclr-description h2').text(), url : checkedRadioButton.attr('data-tree-url') }, function(response) {
      var tree_id = response.tree_id;
      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
          console.log(response);
          if (xhr.status == 200) {
            $('.spinner').remove();
            $('#new-tab').before(response.tree);
            $('#tabs').tabs('add', '#' + response.domid, response.title, $('#tabs').tabs('length') - 2)

            $("#container_for_" + response.domid).jstree({
              "json_data": {
                "ajax": {
                  "url": response.url,
                  "data" : function (node) {
                    if (node.attr) {
                      return { parent_id : node.attr("id") };
                    } else {
                      return {};
                    }
                  }
                },
              },
              "crrm": {
                "move": {
                  "check_move": function(move) { return false; },
                  "always_copy": "multitree"
                },
              },
              "plugins" : [ "themes", "json_data", "ui", "dnd", "crrm"]
            }).addClass('ui-tabs-panel ui-widget-content ui-corner-bottom');

            $('#tabs').tabs();
            $('#tab-titles li:last').prev().prev().find('a').trigger('click');
          } else if (xhr.status == 204) {
            timeout = setTimeout(checkImportStatus, 2000);
          }
        });
      }, 2000);
    }, 'json');
  });
});
