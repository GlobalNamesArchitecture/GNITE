$(document).ready(function() {
  $.fn.spinner = function() {
    if (this[0].spinnerElement) {
      return;
    }

    var position       = this.css('position');
    var spinnerElement = $('<div class="spinner"></div>');

    if (position != 'absolute' && position != 'relative') {
      position = 'relative';
    }

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

            $('#container_for_' + response.domid + ' .jstree-clicked').live('click', function() {
              var self     = $(this);
              var metadata = $('#' + response.domid + ' .node-metadata');

              metadata.spinner();

              $.getJSON('/reference_trees/' + tree_id + '/nodes/' + self.parent('li').attr('id'), function(data) {
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

                var wrapper = $('#add-node-wrap');

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
