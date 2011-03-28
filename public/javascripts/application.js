

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = {
  Tree          : {},
  MasterTree    : {},
  DeletedTree   : {},
  ReferenceTree : {},
  MasterTreeID : $('.tree-container:first').attr('data-database-id')
};


/**************************************************************
           TREE CONFIGURATION
**************************************************************/
GNITE.Tree.configuration = {
  'core' : {
    'strings' : {
        'new_node' : 'New child'
      }
  },

  'themes' : {
    'theme' : 'gnite',
    'icons' : false,
  },

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
       'always_copy' : 'multitree'
    }
  },

  'ui' : {
	'select_limit' : 1
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search']

};

GNITE.MasterTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
  'contextmenu' : {
    'select_node' : true,
    'items'       : function() {
      return {
        'rename' : {
          'label'            : 'Rename',
          'action'           : function(obj) { this.rename(obj); },
          'separator_after'  : false,
          'separator_before' : false,
          'icon'           : 'context-rename',
        },
        'create' : {
          'label'            : 'New child',
          'action'           : function(obj) { this.create(obj); },
          'separator_after'  : true,
          'separator_before' : false,
          'icon'             : 'context-create',
        },
        'cut' : {
          'label'            : 'Cut',
          'action'           : function(obj) { this.cut(obj); },
          'separator_after'  : false,
          'separator_before' : false,
          'icon'           : 'context-cut',
        },
        'paste' : {
          'icon'             : false,
          'label'            : 'Paste',
          'action'           : function(obj) { this.paste(obj); },
          'separator_after'  : false,
          'separator_before' : false,
          'icon'           : 'context-paste',
        },
        'refresh' : {
          'icon'             : false,
          'label'            : 'Refresh',
          'action'           : function(obj) { this.refresh(obj); },
          'separator_after'  : true,
          'separator_before' : true,
          'icon'           : 'context-refresh',
        },
        'remove' : {
          'icon'             : false,
          'label'            : 'Delete',
          'action'           : function(obj) { this.remove(obj); },
          'separator_after'  : false,
          'separator_before' : true,
          'icon'           : 'context-delete',
        },
      };
    }
  },
  'crrm' : {
    'move' : {
      'check_move' : function(m) {
        return true;
/* POSSIBLE MECHANSIM TO CHECK TREE STATUS
        $.ajax({
          url     : '/check_status/' + GNITE.MasterTreeID,
          type    : 'GET',
          success : function(results) {
            return true;
          },
          error : function() {
            return false;
          },
          complete : function() {
            return true;
          }
        });
*/
      }
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search', 'contextmenu']
});

GNITE.ReferenceTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
  'crrm' : {
    'move' : {
      'check_move' : function() { return false; }
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search']
});

GNITE.DeletedTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
  'crrm' : {
    'move' : {
      'check_move' : function() { return false; }
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search']
});

/********************************* jQuery START *********************************/
$(function() {
    
  /*
   * Build the menu system for the master tree
   */
  ddsmoothmenu.init({
    mainmenuid: "toolbar",
    orientation: 'h',
    classname: 'ddsmoothmenu',
    contentsource: "markup",
  });

  ddsmoothmenu.hideMenu = function() {
    $('.toolbar>ul').find("ul").css({display:'none', visibility:'visible'});
  };

  /*
   * New Master Tree title input
   */
  $('#master_tree_title_input')
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

        $.post('/master_trees/' + GNITE.MasterTreeID, { 'master_tree[title]' : title, '_method' : 'put' }, function(response) {
          self
            .next()
              .remove()
            .end()
            .parent()
              .append('<h1>' + title + '</h1>')
            .end()
            .remove();
        }, 'json');
      }
    })
    .keypress(function(event) {
      if (event.which == 13) {
        $(this).blur();
      }
    });

   /*
    * Hide the reference tree tabs
    */
   if ($('#reference-trees li').length == 0) {
     $('#tab-titles li:first-child').hide();
   }

/**************************************************************
           INITIALIZE ALL TREES
**************************************************************/

   /*
   * Initialize the Master Tree
   */
  if ($.fn.jstree) {
    $('#master-tree').jstree($.extend(true, {}, GNITE.MasterTree.configuration, {
      'json_data': {
        'ajax' : {
          'url' : '/master_trees/' + GNITE.MasterTreeID + '/nodes.json'
        }
      },
      'search' : {
        'case_insensitive' : true,
        'ajax' : {
          'url' : '/master_trees/' + GNITE.MasterTreeID + '/tree_expand.json'
        },
      },
    }));
  }

  /*
   * Initialize Reference Trees when drop-down clicked
   */
  $('.reference-tree-container > div').each(function() {
    var self   = $(this);
    var id     = self.attr('id').split('_')[4];
    var active = self.parents('.reference-tree').hasClass('reference-tree-active');

    if (active) {
        $('#reference-trees li a').click(function() {
          if($(this).attr('href').split('_')[2] == id && self.find('ul').length == 0) {
              // Build the menu system for the reference tree
              ddsmoothmenu.init({
                 mainmenuid: "toolbar-reference-"+id,
                 orientation: 'h',
                 classname: 'ddsmoothmenu',
                 contentsource: "markup",
              });
              // Render the reference tree
              self.jstree($.extend(true, {}, GNITE.ReferenceTree.configuration, {
                'json_data' : {
                  'ajax' : {
                    'url' : '/reference_trees/' + id + '/nodes.json'
                  }
                },
                'search' : {
                  'case_insensitive' : true,
                  'ajax' : {
                    'url' : '/reference_trees/' + id + '/name_searches.json'
                  }
                }
              }));
          }
        });
    } else {
      self.parent().spinner();

      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + id + '.json', function(response, status, xhr) {
          if (xhr.status == 200) {
            self.parent().unspinner();
            GNITE.ReferenceTree.add(response);
          } else if (xhr.status == 204) {
            timeout = setTimeout(checkImportStatus, 2000);
          }
        });
      }, 2000);
    }
  });

  /*
   * Initialize Deleted Names when tab clicked
   */
  $('.deleted-tree-container > div').each(function() {
    var self   = $(this);
    var id     = self.attr('id').split('_')[4];
    var active = self.parents('.deleted-tree').hasClass('deleted-tree-active');

    if (active) {
      $('#deleted a').click(function() {
        if(self.find('ul').length == 0) {
          // Render the deleted tree
          self.jstree($.extend(true, {}, GNITE.ReferenceTree.configuration, {
            'json_data' : {
              'ajax' : {
                'url' : '/deleted_tree/' + id + '/nodes.json'
              }
            },
            'search' : {
              'case_insensitive' : true,
              'ajax' : {
                'url' : '/deleted_tree/' + id + '/name_searches.json'
              }
            }
          }));
          // Build the menu system for the deleted tree
          ddsmoothmenu.init({
             mainmenuid: "toolbar-deleted",
             orientation: 'h',
             classname: 'ddsmoothmenu',
             contentsource: "markup",
          });
        }
      });
    }
  });


/**************************************************************
           SEARCH WITHIN TREES
**************************************************************/

  $('.searchicon').hover(function() {
    $(this).addClass('pointer');
  }, function() {
    $(this).removeClass('pointer');
  });

  $('.searchbar-dropdown')
  .hover(function() {
      $(this).find('span').addClass('pointer').addClass('expanded').next().show();
    }, function() {
      $(this).find('span').removeClass('pointer').removeClass('expanded').next().hide(); 
  });

  $('.tree-search')
    .live('blur', function(){
      var self = $(this);
      var tree = self.parents('.tree-background').find('.jstree');
      var term = self.val().trim();
      var $results = self.parents('.tree-background').find('.searchbar-results');
      tree.jstree("clear_search");
      if (term.length > 0) {

        $results.spinner().show();

        $.ajax({
          url     : '/tree_search',
          type    : 'GET',
          data    : { 'tree_id' : self.parents('.tree-background').find('.tree-container').attr('data-database-id'),'name_string' : term },
          success : function(data) {
            var results = '<div class="results-wrapper">';
            if(!data.length) {
              results += '<p>Nothing found</p>';
            }
            for(var i=0; i<data.length; i++) {
              results += '<p><a href="#" data-treepath-ids="' + data[i].treepath.node_ids + '">' + data[i].treepath.name_strings + '</a></p>';
            }
            results += '</div>';
            $results.html(results);
            $results.find("a").click(function() {
               $results.hide();
               tree.jstree("deselect_all");
               var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
               var searched_id = ancestry_arr.pop();
               GNITE.Tree.open_ancestry(tree, ancestry_arr[0], searched_id);
               var timeout = setTimeout(function checkAncestryStatus() {
                if($(searched_id).length > 0) {
	              tree.parents('#add-node-wrap, .reference-tree-container, .deleted-tree-container').scrollTo($(searched_id));
	              tree.jstree("select_node", $(searched_id));
                }
                else {
                  timeout = setTimeout(checkAncestryStatus, 100);
                }
               }, 100);
               return false;
            });
          },
          error : function() {
          },
          complete : function() {
            $results.unspinner();
          }
        });
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        $(this).blur();     
      }
    }).next().click(function() {
        $(this).blur();
    });
  
  GNITE.Tree.open_ancestry = function(tree, obj, terminus, original_obj) {
    if(original_obj) { 
        obj = $(obj).find("li.jstree-closed");
    }
    else {
        original_obj = $(obj);
        if($(obj).is(".jstree-closed")) { obj = $(obj).find("li.jstree-closed").andSelf(); }
        else { obj = $(obj).find("li.jstree-closed"); }
    }
    var _this = this;
    obj.each(function () {
        var __this = this;
        obj = (typeof __this == "[object]") ? __this[0].get("id") : __this;
        tree.jstree("open_node", this, function() {
          if('#' + $(obj).attr("id") !== terminus) {
            _this.open_ancestry(tree, obj, terminus, original_obj);
          } 
        }, true);
    });
  }


/**************************************************************
           TOOL BAR ACTIONS
**************************************************************/

  /*
   * FILE: Add node
   */
  $('.nav-add-node').click(function() {
    $('#master-tree').jstree('create');
    ddsmoothmenu.hideMenu();
    return false;
  });

  /*
   * FILE: Edit Tree Info
   * a href found in Rails view
   */

  /*
   * FILE: Publish tree
   */
  $('.nav-publish-tree').live('click', function() {

    $.ajax({
      type        : 'GET',
      url         : '/master_trees/' + GNITE.MasterTreeID + '/publish.json',
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        var message = 'Your tree is being queued for publishing';
        $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Publishing Confirmation">' + message + '</div>');
        $('#dialog-message').dialog({
            height : 200,
            width : 500,
            modal : true,
            closeText : "",
            buttons: {
                "OK": function() {
                  $('#dialog-message').dialog("destroy").hide().remove();
                }
            },
            draggable : false,
            resizable : false
        });
      }
    });
  });

  /*
   * FILE: Delete tree
   */
  $('.nav-delete-tree').live('click', function() {
    var message = 'Are you sure you want to delete your working tree?';
    $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Delete Confirmation">' + message + '</div>');
    $('#dialog-message').dialog({
        height : 200,
        width : 500,
        modal : true,
        closeText : "",
        buttons: {
            "Delete" : function() {
                var formData = $("form").serialize();
                $.ajax({
                  type        : 'DELETE',
                  url         :  '/master_trees/' + GNITE.MasterTreeID,
                  data        :  formData,
                  success     : function(data) {
                    window.location = "/master_trees";
                  }
                });
            },
            "Cancel": function() {
              $('#dialog-message').dialog("destroy").hide().remove();
            }
        },
        draggable : false,
        resizable : false
    });
  });

  /*
   * EDIT: Edit node
   */
  $('.nav-edit-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('rename');
    }
    ddsmoothmenu.hideMenu();
    return false;
  });

  /*
   * EDIT: Cut
   */
  $('.nav-cut-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('cut');
    }
    ddsmoothmenu.hideMenu();
    return false;
  });

  /*
   * EDIT: Paste
   */
  $('.nav-paste-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('paste');
    }
    ddsmoothmenu.hideMenu();
    return false;
  });

  /*
   * EDIT: Delete node
   */
  $('.nav-delete-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('remove');
    }
    ddsmoothmenu.hideMenu();
    return false;
  });

  GNITE.Tree.buildViewMenuActions = function() {
      /*
       * VIEW: Refresh tree
       * Generic refresh action for any tree
       */
      $('.nav-refresh-tree').click(function() {
        var self = $(this);
        var tree_id = self.parents('.tree-background').find('.jstree').attr("id");
        $('#'+tree_id).jstree('refresh');
        ddsmoothmenu.hideMenu();
        return false;
      });

      /*
       * VIEW: Collapse tree
       * Generic collapse action for any tree
       */
      $('.nav-collapse-tree').click(function() {
        var self = $(this);
        var tree_id = self.parents('.tree-background').find('.jstree').attr("id");
        $('#'+tree_id).jstree('close_all');
        ddsmoothmenu.hideMenu();
        return false;
      });
  }

  GNITE.Tree.buildViewMenuActions();


/**************************************************************
            MASTER TREE ACTIONS
**************************************************************/

  /*
   * ActionType: ActionAddNode
   * Creates node in Master Tree
   */
  $('#master-tree').bind('create.jstree', function(event, data) {
    var node     = data.rslt;
    var name     = node.name;
    var parentID = null;

    if (node.parent != -1) {
      parentID = node.parent.attr('id');
    }

    $.ajax({
      type        : 'POST',
      url         : '/master_trees/' + GNITE.MasterTreeID + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : name }, 'parent_id' : parentID }, 'action_type' : "ActionAddNode" }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        node.obj.attr('id', data.node.id);
      }
    });
  });

  $('#master-tree').bind('loaded.jstree', function(event, data) {
    $('#master-tree').addClass('loaded');
  });

  /*
   * ActionType: ActionRenameNode
   * Renames node in Master Tree
   */
  $('#master-tree').bind('rename.jstree', function(event, data) {
    var node     = data.rslt;
    var id       = node.obj.attr('id');
    var new_name = node.new_name;

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.MasterTreeID + '/nodes/' + id + '.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : new_name } }, 'action_type' : 'ActionRenameNode' }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        updatedNode.obj.attr('id', data.node.id);
      }
    });
  });

  /*
   * ActionType: ActionMoveNodeWithinTree
   * Moves node within Master Tree
   */
  $('#master-tree').bind('move_node.jstree', function(event, data) {
     var result      = data.rslt;
     var isCopy      = result.cy;

     var parentID    = result.np.attr('id');
     var movedNodeID = result.o.attr('id');
     var action_type = "";

     if (parentID == 'master-tree') {
       parentID = null;
     }

     var url = '/master_trees/' + GNITE.MasterTreeID + '/nodes';

     if (isCopy) {
       action_type = "ActionCopyNodeFromAnotherTree";
     } else {
       url = url + '/' + movedNodeID;
       action_type = "ActionMoveNodeWithinTree";
     }

     url += '.json';

     $.ajax({
       type        : isCopy ? 'POST' : 'PUT',
       url         : url,
       data        : JSON.stringify({ 'node' : {'id' : movedNodeID, 'parent_id' : parentID }, 'action_type' : action_type }),
       contentType : 'application/json',
       dataType    : 'json',
       success     : function(data) {
         if (isCopy) {
           result.oc.attr('id', data.node.id);
         } else {
           result.o.attr('id', data.node.id);
         }
       }
     });

  });

  /*
   * ActionType: ActionMoveNodeBetweenTrees
   * Moves node from Master Tree to Deleted Names & refreshes Delete Names
   */
  $('#master-tree').bind('remove.jstree', function(event, data) {
    var node = data.rslt;
    var id   = node.obj.attr('id');

    $.ajax({
      type    : 'PUT',
      url     : '/master_trees/' + GNITE.MasterTreeID + '/nodes/' + id + '.json',
      data    : JSON.stringify({'action_type' : 'ActionMoveNodeToDeletedTree'}),
      contentType : 'application/json',
      success : function(data) {
        var $deleted_tree = $('.deleted_tree .jstree');
        $deleted_tree.jstree("refresh");
      }
    });
  });

  /*
   * Double-click rename
   */
  $('#master-tree .jstree-clicked').live('dblclick', function() {
    $('.jstree-focused').jstree('rename');
  });

  $('#add-node-wrap').live('click', function(event) {
    var target = $(event.target);

    if (event.target.tagName != 'A' && event.target.tagName != 'INS') {
      $('#add-node-wrap').css('bottom', '20px');
      $('#add-node-wrap + .node-metadata').hide();

      target.closest('.jstree').jstree('deselect_all');
    }

    target.find('.jstree').jstree('deselect_all');
  });


/**************************************************************
           METADATA ACTIONS
**************************************************************/

  /*
   * Metadata helper function
   */
  GNITE.Node = {
    getMetadata: function(url, container, wrapper) {
      container.spinner();

      $.getJSON(url, function(data) {
        var rank             = $.trim(data.rank);
        var synonyms         = data.synonyms;
        var vernacular_names = data.vernacular_names;

        container.find('.metadata-section ul').empty();
        container.find('.metadata-rank ul').append('<li>' + rank + '</li>');

        $.each(synonyms, function(index, synonym) {
          container.find('.metadata-synonyms ul').append('<li>' + synonym + '</li>');
        });

        $.each(vernacular_names, function(index, vernacular_name) {
          container.find('.metadata-vernacular-names ul').append('<li>' + vernacular_name + '</li>');
        });

        container.unspinner().show();
        wrapper.css('bottom', container.height());

        var nodePosition  = container[0].offsetTop - wrapper[0].scrollTop;
        var visibleHeight = wrapper.height();

        if (nodePosition >= visibleHeight) {
//          wrapper[0].scrollTop += nodePosition - visibleHeight + 36;
        }
      });
    }
  };

  /*
   * Get Master Tree metadata
   */
  $('#master-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var metadata = $('#treewrap-main .node-metadata');
    var wrapper  = $('#add-node-wrap');
    var url      = '/master_trees/' + GNITE.MasterTreeID + '/nodes/' + self.parent('li').attr('id');

    GNITE.Node.getMetadata(url, metadata, wrapper);
  });

  /*
   * Get Reference Tree metadata
   */
  $('.reference-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var tree     = self.parents('.reference-tree');
    var metadata = tree.find('.node-metadata');
    var tree_id  = tree.attr('id').split('_')[2];
    var node_id  = self.parent('li').attr('id');
    var wrapper  = tree.find('.tree_container > div');
    var url      = '/reference_trees/' + tree_id + '/nodes/' + node_id;

    GNITE.Node.getMetadata(url, metadata, wrapper);
  });


/**************************************************************
           SEARCH & IMPORT FROM GNACLR
**************************************************************/
  $('#gnaclr-search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var container      = self.parents('.gnaclr-search').first();

        container.spinner();

        $.ajax({
          url     : '/gnaclr_search',
          type    : 'GET',
          data    : { 'search_term' : term, 'master_tree_id' : GNITE.MasterTreeID },
          success : function(results) {
            $('#gnaclr-error').hide();
            $('#new-tab .tree-background').html(results);

            $('#search-nav li').each(function() {
              if ($(this).find('.count').text() != '0') {
                $(this).trigger('click');
                return false;
              }
            });
          },
          error : function() {
            $('#gnaclr-error').show();
          },
          complete : function() {
            container.unspinner();
          }
        });
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        $(this).blur();
      }
    });

  $('#browse-gnaclr-button, .ajax-load-new-tab, .gnaclr_classification_show').live('click', function() {
    $('#new-tab').load($(this).attr('href'));

    return false;
  });

  var importTree = function(opts) {
    opts.spinnedElement.spinner()

    $.post('/gnaclr_imports', { master_tree_id : opts.master_tree_id, title : opts.title, url : opts.url, source_id: opts.source_id }, function(response) {
      var tree_id = response.tree_id;
      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
          if (xhr.status == 200) {
            GNITE.ReferenceTree.add(response, opts);
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

    var checkedRadioButton = $('#tree-revisions form input:checked');
    var opts = { master_tree_id : GNITE.MasterTreeID,
                 title          : $('#gnaclr-description h2').text(),
                 url            : checkedRadioButton.attr('data-tree-url'),
                 source_id      : checkedRadioButton.attr('data-source-id'),
                 spinnedElement : $('#tree-newimport') };

    importTree(opts);
  });

  $('#search-nav li').live('click', function() {
    $('#search-nav li.active').removeClass('active');
    $(this).addClass('active');

    $('.search-text').hide();
    $($(this).find('a').attr('href')).show();

    return false;
  });

  $('button.import').live('click', function() {
    var self = $(this);
    var opts = { master_tree_id : GNITE.MasterTreeID,
                 title          : self.parent().siblings('table').find('.current-name').text(),
                 url            : self.attr('data-tree-url'),
                 source_id      : self.attr('data-source-id'),
                 spinnedElement : $('#search-results') };

    importTree(opts);

    return false;
  });


/**************************************************************
           IMPORT FLAT LIST
**************************************************************/

  $('#import-roots-button').live('click', function() {
    var title = $('#import-title').val().trim();
    var roots = $('#import-roots').val().trim();

    var titleLabel = $('#import-title').parent().prev().find('label');
    var rootsLabel = $('#import-roots').parent().prev().find('label');

    if (title == '') {
      if (titleLabel.find('span').length == 0) {
        titleLabel.addClass('error').append('<span> is required.</span>');
      }
    } else {
      titleLabel.removeClass('error').find('span').remove();
    }

    if (roots == '') {
      if (rootsLabel.find('span').length == 0) {
        rootsLabel.addClass('error').append('<span> is required.</span>');
      }
    } else {
      rootsLabel.removeClass('error').find('span').remove();
    }

    if (title == '' || roots == '') {
      return false;
    }

    var data = JSON.stringify({
      'nodes_list'     : roots.split("\n"),
      'reference_tree' : {
        'title'          : title,
        'master_tree_id' : GNITE.MasterTreeID
      }
    });

    $.ajax({
      url         : $(this).parent('form').attr('action') + '.json',
      type        : 'POST',
      data        : data,
      contentType : 'application/json',
      success     : function(response) {
        GNITE.ReferenceTree.add(response);
      }
    });

    return false;
  });

});

/**************************************************************
           DYNAMICALLY ADD REFERENCE TREE
**************************************************************/

GNITE.ReferenceTree.add = function(response, options) {
  if ($('a[href="#' + response.domid + '"]').length == 0) {
    var tab   = $('#all-tabs');
    var count = parseInt(tab.text().replace(/[^0-9]+/, ''), 10);

    tab.text('All reference trees (' + (count + 1) + ')');

    $('#new-tab').before(response.tree);

    $('#tab-titles li:first-child').show();
    $('#tabs li:first-child ul').append('<li><a href="#' + response.domid + '">' + response.title + '</a></li>');
  }

  $('#container_for_' + response.domid).jstree($.extend(true, {},
    GNITE.ReferenceTree.configuration, {
      'json_data' : {
        'ajax' : {
          'url' : response.url
        }
      }
    }
  ));

  $('#tabs li:first-child ul li:last-child a').trigger('click');

  // Build the menu system for the new reference tree
/* TODO: rendering of "View" drop-down menu is not correct
  ddsmoothmenu.init({
     mainmenuid: "toolbar-reference-"+response.domid.split('_')[2],
     orientation: 'h',
     classname: 'ddsmoothmenu',
     contentsource: "markup",
  });

  GNITE.Tree.buildViewMenuActions();
*/

  if (options) {
    options.spinnedElement.unspinner()
  }

};

/********************************* jQuery END *********************************/




/**************************************************************
           CUSTOM jQuery PLUGINS
**************************************************************/

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

