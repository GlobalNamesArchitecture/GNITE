$(function() {
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

  var importTree = function(opts){
    opts.spinnedElement.spinner()
    $.post('/gnaclr_imports', { master_tree_id : opts.master_tree_id, title : opts.title, url : opts.url }, function(response) {
      var tree_id = response.tree_id;
      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
          if (xhr.status == 200) {
            opts.spinnedElement.unspinner()
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

                var wrapper = $('#container_for_' + response.domid);

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
  };

  $('#import-gnaclr-button').live('click', function() {
    $('#tree-newimport').spinner();
    $('#import-gnaclr-button').remove();

    var checkedRadioButton = $("#tree-revisions form input:checked");
    var opts = { master_tree_id : $("#tree-container").attr("data-database-id"),
                 title          : $('#gnaclr-description h2').text(),
                 url            : checkedRadioButton.attr('data-tree-url'),
                 spinnedElement : $("#tree-newimport") };
    importTree(opts);
  });

  $("#search-nav li").live("click", function(){
    var target = $(this).find("a").attr("href");
    $(".search-text").fadeOut("fast");
    $(target).fadeIn("fast");
    return false;
  });

  $("button.import").live("click", function(){
    self = $(this);
    var opts = { master_tree_id : $("#tree-container").attr("data-database-id"),
                 title          : self.siblings("div.current_name").text(),
                 url            : self.attr('data-tree-url'),
                 spinnedElement : $("#search-results") };
    importTree(opts);
    return false;
  });
});




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
        var container = self.parents('.gnaclr-search').first();
        container.spinner();

        $.ajax({
          url: '/search',
          type: 'GET',
          data: 'search_term=' + term,
          success: function(results){
            container.unspinner();
            $("#gnaclr-error").hide();
            $('#new-tab .tree-background').html(results);
          },
          error: function(){
            container.unspinner();
            $("#gnaclr-error").show();
          }
        });
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        $(this).blur();
      }
    });
});




/*
 * Master Tree
 */
$(function() {
  var master_tree_id = $('#tree-container').attr('data-database-id');

  function contextMenuItems() {
    return {
      "create" : {
        "separator_before"  : false,
        "separator_after"  : true,
        "label"        : "Create",
        "action"      : function (obj) { this.create(obj); }
      },
      "rename" : {
        "separator_before"  : false,
        "separator_after"  : false,
        "label"        : "Rename",
        "action"      : function (obj) { this.rename(obj); }
      },
      "remove" : {
        "separator_before"  : false,
        "icon"        : false,
        "separator_after"  : true,
        "label"        : "Delete",
        "action"      : function (obj) { this.remove(obj); }
      },
      "cut" : {
        "separator_before"  : false,
        "separator_after"  : false,
        "label"        : "Cut",
        "action"      : function (obj) { this.cut(obj); }
      },
      "paste" : {
        "separator_before"  : false,
        "icon"        : false,
        "separator_after"  : false,
        "label"        : "Paste",
        "action"      : function (obj) { this.paste(obj); }
      }
    }
  }

  $("#add-node").click(function() {
    $("#master-tree").jstree("create");
  });

  $("#master-tree").jstree({
    "json_data": {
      "ajax": {
      "url": '/master_trees/' + master_tree_id + '/nodes.json',
        "data" : function (node) {
          if (node.attr) {
            return { parent_id : node.attr('id').replace('copy_', '') };
          } else {
            return {};
          }
        }
      },
    },
    "contextmenu": {
      select_node: true,
      items : contextMenuItems
    },
    "crrm": {
      "move": {
        "always_copy": "multitree"
      },
    },
    "plugins" : [ "themes", "json_data", "crrm", "ui",  "contextmenu", "dnd"]
  });


  $("#master-tree")
  .bind("create.jstree", function(event, data) {
    var newNode = data.rslt;

    var parentId;
    if (newNode.parent == -1) {
      parentId = null;
    } else {
      parentId = newNode.parent.attr("id");
    }

    $.ajax({
      type: "POST",
      url: '/master_trees/' + master_tree_id + '/nodes.json',
      contentType: "application/json",
      dataType: 'json',
      data: JSON.stringify({node: {name: { name_string : newNode.name }, parent_id: parentId}}),
      success: function(data, textStatus, xhr) {
        newNode.obj.attr("id", data.node.id);
      }
    });
  });

  $("#master-tree").bind("loaded.jstree", function(event, data) {
    $("#master-tree").addClass("loaded");
  });

  $("#master-tree").bind("rename.jstree", function(event, data) {
    var updatedNode = data.rslt;
    $.ajax({
      type: "POST",
      url: "/master_trees/" + master_tree_id + "/nodes/"+updatedNode.obj.attr("id")+"/name_updates.json",
      contentType: "application/json",
      dataType: 'json',
      data: JSON.stringify({name: { name_string: updatedNode.new_name } }),
      success: function(data, textStatus, xhr) {
        updatedNode.obj.attr("id", data.node.id);
      }
    });
  });

  $("#master-tree").bind("move_node.jstree", function(event, data) {
     var result = data.rslt;
     var movedNodeId = result.o.attr("id");
     var parentId = result.np.attr("id");
     var isCopy = data.rslt.cy;
     if(parentId == "master-tree"){
       parentId = null;
     }

     if (isCopy) {
       $.ajax({
         type: "POST",
         url: "/master_trees/" + master_tree_id + "/nodes/" + movedNodeId + "/clone.json",
         contentType: "application/json",
         dataType: 'json',
         data: JSON.stringify({node: {parent_id: parentId }}),
         success: function(data, textStatus, xhr) {
           result.oc.attr('id', data.node.id);
         }
       });
     } else {
       $.ajax({
         type: "PUT",
         url: "/master_trees/" + master_tree_id + "/nodes/"+result.o.attr("id")+".json",
         contentType: "application/json",
         dataType: 'json',
         data: JSON.stringify({node: {parent_id: parentId }}),
         success: function(data, textStatus, xhr) {
           result.o.attr("id", data.node.id);
         }
       });
     }
  });

  $("#master-tree").bind("remove.jstree", function(event, data) {
    var node = data.rslt;
    $.ajax({
      type: "DELETE",
      url: "/master_trees/" + master_tree_id + "/nodes/"+node.obj.attr("id")+".json",
      contentType: "application/json",
      dataType: 'json',
    });
  });

  $('#master-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var metadata = $('#treewrap-left .node-metadata');

    metadata.spinner();

    $.getJSON('/master_trees/' + master_tree_id + '/nodes/' + self.parent('li').attr('id'), function(data) {
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

  $('#master-tree .jstree-clicked').live('dblclick', function() {
    $(".jstree-focused").jstree("rename");
  });

  $('#add-node-wrap').live('click', function(event) {
    var hitNode = (event.target.tagName == 'A') ||
                  (event.target.tagName == 'INS');

    if (!hitNode) {
      $(event.target).closest('.jstree').jstree('deselect_all');
      $('#add-node-wrap + .node-metadata').hide();
      $('#add-node-wrap').css('bottom', '20px');
    }
  });

  $('#add-node-wrap').live('click', function(event) {
    $(event.target).find('.jstree').jstree('deselect_all');
  });

  $('#master_tree_title')
    .focus()
    .blur(function() {
      var self = $(this);

      if ($.trim(self.val()) == '') {
        setTimeout(function() {
          self.focus();
        }, 10);

        self.next().text('Please enter a title for your tree.').addClass('error');
      } else {
        var title = self.val();

        $.post('/master_trees/' + master_tree_id, { 'master_tree[title]' : title, '_method' : 'put' }, function() {
          self
            .next()
              .remove()
            .end()
            .parent()
              .append('<h1>' + title + '</h1>')
            .end()
            .remove();
        });
      }
    })
    .keypress(function(event) {
      if (event.which == 13) {
        $(this).blur();
      }
    });
});
