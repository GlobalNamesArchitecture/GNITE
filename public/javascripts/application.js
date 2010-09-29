$(document).ready(function() {

  $.fn.spinner = function() {
    if (this[0].spinnerElement) {
      return;
    }

    var spinnerElement = $('<div class="spinner"></div>');
    var position       = this.css('position') == 'absolute' || this.css('position') == 'relative' ? this.css('position') : 'relative';

    this
      .css('position', position)
      .prepend(spinnerElement);

    spinnerElement.fadeIn('fast');

    return this.each(function () {
      this.spinnerElement = spinnerElement[0];
    });
  };

  $.fn.unspinner = function() {
    this.each(function () {
      if (this.spinnerElement) {
        $(this.spinnerElement).fadeOut('fast', function() {
          $(this).remove();
        });

        this.spinnerElement = null;
      }
    });
    return this;
  };

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
    $('#tree-newimport').spinner();
    $('#import-gnaclr-button').remove();

    var checkedRadioButton = $("#tree-revisions form input:checked");
    $.post('/gnaclr_imports', { master_tree_id : $('#tree-container').attr('data-database-id'), title : $('#gnaclr-description h2').text(), url : checkedRadioButton.attr('data-tree-url') }, function(response) {
      var tree_id = response.tree_id;
      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
          if (xhr.status == 200) {
            $('#tree-newimport').unspinner()
            $('#new-tab').before(response.tree);

            $('#tab-titles li:first-child').show();
            $('#tabs li:first-child ul').append('<li><a href="#' + response.domid + '">' + response.title + '</a></li>');

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
            });

            $('#tabs li:first-child ul li:last-child a').trigger('click');
          } else if (xhr.status == 204) {
            timeout = setTimeout(checkImportStatus, 2000);
          }
        });
      }, 2000);
    }, 'json');
    return false;
  });

});
