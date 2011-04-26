
/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = {
  Tree : {
    MasterTree      : {},
    DeletedTree     : {},
    ReferenceTree   : {},
    Node            : {}
  }
};

/********************************* jQuery START *********************************/
$(function() {

  GNITE.Tree.MasterTree.id = $('.tree-container:first').attr('data-database-id');

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
      'select_limit' : -1,
      'select_multiple_modifier' : "shift"
    },

    'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'hotkeys']

  };

  GNITE.Tree.MasterTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
    'contextmenu' : {
      'select_node' : true,
      'items'       : function() {
        return {
          'rename' : {
            'label'            : 'Rename',
            'action'           : function(obj) { this.rename(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-rename',
          },
          'create' : {
            'label'            : 'New child',
            'action'           : function(obj) { this.create(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-create',
          },
          'bulk-create' : {
            'label'            : 'New children',
            'action'           : function(obj) { this.bulk_form(obj); },
            'separator_after'  : true,
            'separator_before' : false,
            'icon'             : 'context-create-bulk',
          },
          'cut' : {
            'label'            : 'Cut',
            'action'           : function(obj) { this.cut(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-cut',
          },
          'paste' : {
            'label'            : 'Paste',
            'action'           : function(obj) { this.paste(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-paste',
          },
          'refresh' : {
            'label'            : 'Refresh',
            'action'           : function(obj) { this.refresh(obj); },
            'separator_after'  : false,
            'separator_before' : true,
            'icon'             : 'context-refresh',
          },
          'bookmark' : {
            'label'            : 'Add bookmark',
            'action'           : function(obj) { this.bookmarks_form(obj); },
            'separator_after'  : true,
            'separator_before' : false,
            'icon'             : 'context-bookmark'
          },
          'remove' : {
            'label'            : 'Delete',
            'action'           : function(obj) { this.remove(obj); },
            'separator_after'  : false,
            'separator_before' : true,
            'icon'             : 'context-delete',
          },
        };
      }
    },
    'hotkeys' : {
      'return'       : function() { if(this.data.ui.hovered) { this.data.ui.hovered.children("a:eq(0)").click(); } },
      'ctrl+n'       : function() { this.create( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+shift+n' : function() {
        var node = (this.data.ui.hovered || this._get_node(null)) ? (this.data.ui.hovered || this._get_node(null)) : null;
        this.bulk_form(node); 
      },
      'ctrl+r'       : function() { this.refresh( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+shift+r' : function() { this.refresh(); },
      'ctrl+b'       : function() { this.bookmarks_form( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+e'       : function() { this.rename( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+c'       : function() { this.cut( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+v'       : function() { this.paste( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+d'       : function() { this.remove( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+z'       : function() { this.undo(); },
      'ctrl+shift+z' : function() { this.redo(); },
      'ctrl+s'       : function() { GNITE.Tree.MasterTree.publish(); } 
    },
    'bookmarks' : {
      'addition_form' : '#bookmarks-addition-form-' + GNITE.Tree.MasterTree.id,
      'viewer_form'   : '#bookmarks-results-' + GNITE.Tree.MasterTree.id
    },
    'bulkcreate' : {
      'element' : '#bulkcreate-form'
    },

    'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search', 'contextmenu', 'bookmarks', 'hotkeys', 'bulkcreate', 'undoredo']
  });

  GNITE.Tree.ReferenceTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
    'crrm' : {
      'move' : {
        'check_move' : function() { return false; }
      }
    },

    'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'bookmarks', 'hotkeys']
  });

  GNITE.Tree.DeletedTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
    'crrm' : {
      'move' : {
        'check_move' : function() { return false; }
      }
    },

    'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'hotkeys']
  });


  /*
   * Build the menu system for the master tree
   */
  ddsmoothmenu.init({
    mainmenuid: "toolbar",
    orientation: 'h',
    classname: 'ddsmoothmenu',
    contentsource: "markup",
  });

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

        $.post('/master_trees/' + GNITE.Tree.MasterTree.id, { 'master_tree[title]' : title, '_method' : 'put' }, function(response) {
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
    $('#master-tree').jstree($.extend(true, {}, GNITE.Tree.MasterTree.configuration, {
      'json_data': {
        'ajax' : {
          'url' : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes.json'
        }
      },
      'hotkeys' : {
        'ctrl+shift+b' : function() { this.bookmarks_view(); }
      }
    }));
  }

  /*
   * Initialize Reference Trees when drop-down clicked
   */
  $('.reference-tree-container > div').each(function() {
    var self   = $(this);
    var tree_id     = self.attr('id').split('_')[4];
    var active = self.parents('.reference-tree').hasClass('reference-tree-active');

    if (active) {
        $('#reference-trees li a').click(function() {
          if($(this).attr('href').split('_')[2] == tree_id && self.find('ul').length == 0) {
              // Render the reference tree
              self.jstree($.extend(true, {}, GNITE.Tree.ReferenceTree.configuration, {
                'json_data' : {
                  'ajax' : {
                    'url' : '/reference_trees/' + tree_id + '/nodes.json'
                  }
                },
                'bookmarks' : {
                    'viewer_form'   : '#bookmarks-results-' + tree_id,
                    'addition_form' : '#bookmarks-addition-form-' + tree_id
                }
              }));

              self.bind('bookmarks_form.jstree', function(event, data) {
                $('#bookmarks-addition-form-' + tree_id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
              });

              self.bind('bookmarks_view.jstree', function(event, data) {
                GNITE.Tree.viewBookmarks(this);
              });

              self.bind('bookmarks_save.jstree', function(event, data) {
                var node = data.rslt;
                var id   = node.obj.attr('id');
                var title = $('#bookmark-title-' + tree_id).val();

                $.ajax({
                  type        : 'POST',
                  url         : '/reference_trees/' + tree_id + '/bookmarks',
                  data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
                  contentType : 'application/json',
                  dataType    : 'json',
                  success     : function(data) {
                  }
                });
              });

              // Build the menu system for the reference tree
              self.bind("init.jstree", function(event, data) {
                ddsmoothmenu.init({
                  mainmenuid: "toolbar-reference-"+tree_id,
                  orientation: 'h',
                  classname: 'ddsmoothmenu',
                  contentsource: "markup",
                });
              });

          }
        });
    } else {

      $('#toolbar-reference-' + tree_id + ' ul').hide();

      self.parent().spinner();

      var timeout = setTimeout(function checkImportStatus() {
        $.get('/reference_trees/' + tree_id + '.json', function(response, status, xhr) {
          if (xhr.status == 200) {
            self.parent().unspinner();
            GNITE.Tree.ReferenceTree.add(response);
            $('#toolbar-reference-' + tree_id + ' ul').show();
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
          self.jstree($.extend(true, {}, GNITE.Tree.ReferenceTree.configuration, {
            'json_data' : {
              'ajax' : {
                'url' : '/deleted_trees/' + id + '/nodes.json'
              }
            }
          }));

          // Build the menu system for the deleted tree
          self.bind("init.jstree", function(event, data) {
            ddsmoothmenu.init({
              mainmenuid: "toolbar-deleted",
              orientation: 'h',
              classname: 'ddsmoothmenu',
              contentsource: "markup",
            });
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
    .live('blur', function() {
      var self = $(this);
      var tree = self.parents('.tree-background').find('.jstree');
      var term = self.val().trim();
      var $results = self.parents('.tree-background').find('.searchbar-results');
      if (term.length > 0) {

        $results.spinner().show();

        $.ajax({
          url     : '/tree_searches/' + self.parents('.tree-background').find('.tree-container').attr('data-database-id') + '/' + term,
          type    : 'GET',
          data    : { },
          success : function(data) {
            var results = '<div class="results-wrapper">';
            if(!data.length) {
              results += data.status;
            }
            else {
                results += '<ul>';
                for(var i=0; i<data.length; i++) {
                  results += '<li><a href="#" data-treepath-ids="' + data[i].treepath.node_ids + '">' + data[i].treepath.name_strings + '</a></li>';
                }
                results += '</ul>';
            }
            results += '</div>';
            $results.html(results);

            $results.find("a").click(function() {
               $results.hide();
               tree.jstree("deselect_all");
               var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
               var searched_id = ancestry_arr.pop();
               GNITE.Tree.openAncestry(tree, ancestry_arr[0], searched_id);
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
      //enter key
      if (event.which == 13) {
        $(this).blur();
      }
    })
    .next().click(function() {
        $(this).blur();
    });


/**************************************************************
           TOOL BAR ACTIONS
**************************************************************/

  /*
   * FILE: Add single node
   */
  $('.nav-add-node').click(function() {
    $('#master-tree').jstree('create');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * FILE: Add many nodes
   */
  $('.nav-add-node-bulk').click(function() {
    $("#master-tree").jstree('bulk_form');
    GNITE.Tree.hideMenu();
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
    GNITE.Tree.MasterTree.publish();
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
        buttons: [
          {
            className : "green-submit",
            text : "Delete",
            click : function() {
              var formData = $("form").serialize();
              $.ajax({
                type        : 'DELETE',
                url         :  '/master_trees/' + GNITE.Tree.MasterTree.id,
                data        :  formData,
                success     : function(data) {
                  window.location = "/master_trees";
                }
              });
           }
         },
         {
           className : "cancel-button",
           text : "Cancel",
           click : function() {
             $('#dialog-message').dialog("destroy").hide().remove();
           }
         }
       ],
       draggable : false,
       resizable : false
    });
  });

  /*
   * EDIT: Undo
   */
  $('.nav-undo').click(function() {
    $('#master-tree').jstree('undo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Redo
   */
  $('.nav-redo').click(function() {
    //refresh affected parent(s) after redo
    $('#master-tree').jstree('redo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Edit node
   */
  $('.nav-edit-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('rename');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Cut
   */
  $('.nav-cut-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('cut');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Paste
   */
  $('.nav-paste-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('paste');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Delete node
   */
  $('.nav-delete-node').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('remove');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  GNITE.Tree.buildViewMenuActions();


/**************************************************************
            MASTER TREE ACTIONS
**************************************************************/

  /*
   * ActionType: ActionAddNode
   * Creates node in Master Tree
   */
  $('#master-tree').bind('create.jstree', function(event, data) {

    var self     = $(this);
    var node     = data.rslt;
    var name     = node.name;
    var parentID = null;

    if (node.parent != -1) {
      parentID = node.parent.attr('id');
    }

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'POST',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : name }, 'parent_id' : parentID }, 'action_type' : "ActionAddNode" }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        //unlock the tree
        self.jstree("unlock");

        node.obj.attr('id', data.node.id);
      }
    });
  });

  /*
   * ActionType: ActionAddNode (bulk insert)
   * Creates nodes in Master Tree
   */
  $('#master-tree').bind('bulk_form.jstree', function(event, data) {
    var node = data.rslt;
    var title = (typeof node.obj.attr("id") !== "undefined") ? $(node.obj).find("a:first").text() : 'Tree root';
    $("#bulkcreate-form").dialog("open");
    $('#bulkcreate-list').val("");
    $("#ui-dialog-title-bulkcreate-form").text(title);
  });

  $('#master-tree').bind('bulk_save.jstree', function(event, data) {
    var self = $(this);
    var node = data.rslt;
    var parent_id = (typeof node.obj.attr("id") !== "undefined") ? node.obj.attr("id") : GNITE.Tree.MasterTree.root;

    nodes = $('#bulkcreate-list').val();

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'POST',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'parent_id' : parent_id, 'name' : { 'name_string' : null } }, 'nodes_list' : { 'data' : nodes }, 'action_type' : "ActionAddNode" }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        // unlock the tree
        self.jstree("unlock");

        if(typeof node.obj.attr("id") !== "undefined") {
          self.jstree("refresh", node.obj).jstree("open_node", node.obj);
          $('#'+parent_id).removeClass("jstree-leaf").removeClass("jstree-closed").addClass("jstree-open");
        }
        else {
          self.jstree("refresh");
        }
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

    var self     = $(this);
    var node     = data.rslt;
    var id       = node.obj.attr('id');
    var new_name = node.new_name;

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'PUT',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + id + '.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : new_name } }, 'action_type' : 'ActionRenameNode' }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        //unlock the tree
        self.jstree("unlock");

        node.obj.attr('id', data.node.id);
      }
    });
  });

  /*
   * ActionType: ActionCopyNodeFromAnotherTree and ActionMoveNodeWithinTree
   * Moves node within Master Tree
   */
  $('#master-tree').bind('move_node.jstree', function(event, data) {

     var self = $(this);
     var result = data.rslt;
     var isCopy = result.cy;

     var parentID = result.np.attr('id');
     var action_type = "";

     if (parentID == 'master-tree') {
       parentID = GNITE.Tree.MasterTree.root;
     }
    
     if (isCopy) {
       action_type = "ActionCopyNodeFromAnotherTree";
     } else {
       action_type = "ActionMoveNodeWithinTree";
     }

     // lock the tree
     self.jstree("lock");

     data.rslt.o.each(function(i) {

       var movedNodeID = $(this).attr("id");
       var url = '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes';
       if(!isCopy) url += '/' + movedNodeID;
       url += '.json';

       $.ajax({
           type        : isCopy ? 'POST' : 'PUT',
           async       : false,
           url         : url,
           data        : JSON.stringify({ 'node' : {'id' : movedNodeID, 'parent_id' : parentID }, 'action_type' : action_type }),
           contentType : 'application/json',
           dataType    : 'json',
           success     : function(data) {
           }
        });
    });

    //unlock the tree
    self.jstree("unlock");

    if (isCopy) {
      data.rslt.oc.attr('id', data.node.id);
    } else {
      $(this).attr('id', data.node.id);
    }

  });

  /*
   * ActionType: ActionMoveNodeBetweenTrees
   * Moves node from Master Tree to Deleted Names & refreshes Deleted Names
   */
  $('#master-tree').bind('remove.jstree', function(event, data) {
    var self = $(this);
    var node = data.rslt;

    // lock the tree
    self.jstree("lock");

    node.obj.each(function(i) {
      var id = $(this).attr('id');
      $.ajax({
        type    : 'PUT',
        async   : false,
        url     : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + id + '.json',
        data    : JSON.stringify({'action_type' : 'ActionMoveNodeToDeletedTree'}),
        contentType : 'application/json',
        success : function(data) {
        }
      });
    });

    // unlock the tree
    self.jstree("unlock");

   // refresh the deleted tree
   $('.deleted-tree-container .jstree').jstree("refresh");

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

  /*
   * Undo binding
   */
  $('#master-tree').bind('undo.jstree', function(event, data) {
    var self = $(this);

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'GET',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/undo',
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        // unlock the tree
        self.jstree("unlock");

        GNITE.Tree.MasterTree.flashNode(data);
      }
    });

  });

  /*
   * Redo binding
   */
  $('#master-tree').bind('redo.jstree', function(event, data) {
    var self = $(this);

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'GET',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/redo',
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        // unlock the tree
        self.jstree("unlock");

        GNITE.Tree.MasterTree.flashNode(data);
      }
    });

  });

  /*
   * Bookmark a node binding
   */
  $('#master-tree').bind('bookmarks_form.jstree', function(event, data) {
    $('#bookmarks-addition-form-' + GNITE.Tree.MasterTree.id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
  });

  $('#master-tree').bind('bookmarks_view.jstree', function(event, data) {
    GNITE.Tree.viewBookmarks(this);
  });

  $('#master-tree').bind('bookmarks_save.jstree', function(event, data) {
    var node = data.rslt;
    var id   = node.obj.attr('id');
    var title = $('#bookmark-title-' + GNITE.Tree.MasterTree.id).val();

    $.ajax({
      type        : 'POST',
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/bookmarks',
      data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {}
    });

  });

  /*
   * TODO: Implement node.js or similar AND record state in db
   * Lock the tree
   */
  $('#master-tree').bind('lock.jstree', function(event, data) {
  });

  /*
   * TODO: Implement node.js or similar AND record state in db
   * Unlock the tree
   */
  $('#master-tree').bind('unlock.jstree', function(event, data) {
  });


/**************************************************************
           METADATA ACTIONS
**************************************************************/

  /*
   * Get Master Tree metadata
   */
  $('#master-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var metadata = $('#treewrap-main .node-metadata');
    var wrapper  = $('#add-node-wrap');
    var url      = '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + self.parent('li').attr('id');

    GNITE.Tree.Node.getMetadata(url, metadata, wrapper);
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
    var wrapper  = tree.find('.reference-tree-container');
    var url      = '/reference_trees/' + tree_id + '/nodes/' + node_id;

    GNITE.Tree.Node.getMetadata(url, metadata, wrapper);
  });

/**************************************************************
           SEARCH & IMPORT FROM GNACLR
**************************************************************/
  $('#gnaclr-search')
    .live('blur', function() {
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var container      = self.parents('.gnaclr-search').first();

        container.spinner();

        $.ajax({
          url     : '/gnaclr_searches',
          type    : 'GET',
          data    : { 'search_term' : term, 'master_tree_id' : GNITE.Tree.MasterTree.id },
          format  : 'html',
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
      // enter key
      if (event.which == 13) {
        $(this).blur();
      }
    });

  $('#browse-gnaclr, .ajax-load-new-tab, .gnaclr_classification_show').live('click', function() {
    $('#new-tab').load($(this).attr('href'));
    return false;
  });

  $('#import-gnaclr').live('click', function() {
    var self = $(this);

    $('#tree-newimport').spinner();
    $('#import-gnaclr').remove();

    var checkedRadioButton = $('#tree-revisions form input:checked');
    var opts = { 
      master_tree_id   : GNITE.Tree.MasterTree.id,
      title            : checkedRadioButton.attr('data-tree-title'),
      url              : checkedRadioButton.attr('data-tree-url'),
      revision         : checkedRadioButton.attr('data-revision'),
      publication_date : checkedRadioButton.attr('data-publication-date'),
      spinnedElement : $('#tree-newimport') 
    };
    GNITE.Tree.importTree(opts);
  });

  $('button.gnaclr-import').live('click', function() {
    var self = $(this);
    var opts = { 
      master_tree_id   : GNITE.Tree.MasterTree.id,
      title            : self.attr('data-tree-title'),
      url              : self.attr('data-tree-url'),
      revision         : self.attr('data-revision'),
      publication_date : self.attr('data-publication-date'),
      spinnedElement   : $('#gnaclr-search-results') 
    };
    GNITE.Tree.importTree(opts);
    return false;
  });

  $('#search-nav li').live('click', function() {
    $('#search-nav li.active').removeClass('active');
    $(this).addClass('active');

    $('.search-text').hide();
    $($(this).find('a').attr('href')).show();

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
        'master_tree_id' : GNITE.Tree.MasterTree.id
      }
    });

    $.ajax({
      url         : $(this).parent('form').attr('action') + '.json',
      type        : 'POST',
      data        : data,
      contentType : 'application/json',
      success     : function(response) {
        GNITE.Tree.ReferenceTree.add(response);
      }
    });

    return false;
  });

});
/********************************* jQuery END *********************************/


/**************************************************************
           HELPER FUNCTIONS
**************************************************************/

GNITE.Tree.hideMenu = function() {
  $('.toolbar>ul').find("ul").css({display:'none', visibility:'visible'});
};

GNITE.Tree.openAncestry = function(tree, obj, terminus, original_obj) {
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
          _this.openAncestry(tree, obj, terminus, original_obj);
        }
      }, true);
  });
};

GNITE.Tree.buildViewMenuActions = function() {
  /*
  * VIEW: Refresh tree
  * Generic refresh action for any tree
  */
  $('.nav-refresh-tree').click(function() {
    var self = $(this);
    var tree_id = self.parents('.tree-background').find('.jstree').attr("id");
    $('#'+tree_id).jstree('refresh');
    GNITE.Tree.hideMenu();
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
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * BOOKMARKS: Add
   */
  $('.nav-bookmarks-add').click(function() {
    var self = $(this);
    var tree_id = self.parents('.tree-background').find('.jstree').attr("id");
    $('#'+tree_id).jstree('bookmarks_form');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * BOOKMARKS: View
   */
  $('.nav-bookmarks-view').click(function() {
    var self = $(this);
    var tree_id = self.parents('.tree-background').find('.jstree').attr("id");
    $('#'+tree_id).jstree('bookmarks_view');
    GNITE.Tree.hideMenu();
  });
};

GNITE.Tree.viewBookmarks = function(obj) {

  var self = $(obj);
  var tree = self.parents('.tree-background').find('.jstree');
  var tree_id = tree.attr("id").split('_');
  var url = (tree_id[0] == 'master-tree') ? '/master_trees/' + GNITE.Tree.MasterTree.id + '/bookmarks' : '/reference_trees/' + tree_id[4] + '/bookmarks';
  var id = (tree_id[0] == 'master-tree') ? GNITE.Tree.MasterTree.id : tree_id[4];

  var $bookmarks = $('#bookmarks-results-' + id);
  $bookmarks.html("").spinner().dialog("open");

  $.ajax({
    url     : url,
    type    : 'GET',
    data    : { },
    success : function(data) {
      var results = '<div class="bookmarks-wrapper">';
      if(!data.length) {
        results += '<p>' + data.status + '</p>';
      }
      else {
          results += '<ul>';
          for(var i=0; i<data.length; i++) {
            results += '<li>';
            results += '<a href="#" class="bookmarks-show" data-treepath-ids="' + data[i].bookmark.treepath + '">' + data[i].bookmark.title + '</a>';
            results += '<a href="#" class="bookmarks-delete" data-node-id="' + data[i].bookmark.id + '">Delete</a>';
            results += '</li>';
          }
          results += '</ul>';
      }
      results += '</div>';
      $bookmarks.html(results);

      // Click a bookmark in list
      $bookmarks.find("a.bookmarks-show").click(function() {
         tree.jstree("deselect_all");
         var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
         var searched_id = ancestry_arr.pop();
         GNITE.Tree.openAncestry(tree, ancestry_arr[0], searched_id);
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

      // Delete a bookmark in list
      $bookmarks.find("a.bookmarks-delete").click(function() {
        var self = this;
        $.ajax({
          url   : url + '/' + $(self).attr("data-node-id"),
          type  : 'DELETE',
          data  : { },
          success : function() {
            $(self).parent().remove();
          }
        });
        return false;
      });

    },
    complete : function() {
      $bookmarks.unspinner();
    }
  });

  GNITE.Tree.hideMenu();
  return false;
};

GNITE.Tree.importTree = function(opts) {
  opts.spinnedElement.spinner();

  $.post('/gnaclr_imports', { master_tree_id : opts.master_tree_id, title : opts.title, url : opts.url, revision: opts.revision, publication_date : opts.publication_date }, function(response) {
    var tree_id = response.tree_id;
    var timeout = setTimeout(function checkImportStatus() {
      $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
        if (xhr.status == 200) {
          GNITE.Tree.ReferenceTree.add(response, opts);
        } else if (xhr.status == 204) {
          timeout = setTimeout(checkImportStatus, 2000);
        }
      });
    }, 2000);
  }, 'json');
  return false;
};

GNITE.Tree.MasterTree.publish = function() {
  $.ajax({
    type        : 'GET',
    url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/publish.json',
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
        buttons: [
          {
            className : "green-submit",
            text      : "OK",
            click     : function() { $(this).dialog("close"); }
          }
        ],
        draggable : false,
        resizable : false
      });
    }
  });
};

GNITE.Tree.MasterTree.flashNode = function(data) {
  for (first in data) break;
  if(data[first].destination_parent_id) {
    $('#master-tree').jstree("refresh", $('#'+data[first].destination_parent_id));
    $('#' + data[first].destination_parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
  }
  if(data[first].destination_parent_id != data[first].parent_id) {
    $('#master-tree').jstree("refresh", $('#'+data[first].parent_id));
    $('#' + data[first].parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
  }
};

GNITE.Tree.ReferenceTree.add = function(response, options) {
  if ($('a[href="#' + response.domid + '"]').length == 0) {
    var tab   = $('#all-tabs');
    var count = parseInt(tab.text().replace(/[^0-9]+/, ''), 10);

    tab.text('All reference trees (' + (count + 1) + ')');

    $('#new-tab').before(response.tree);

    $('#tab-titles li:first-child').show();
    $('#reference-trees').append('<li><a href="#' + response.domid + '">' + response.title + '</a></li>');
  }

  var tree_id = response.domid.split('_')[2];

  $('#container_for_' + response.domid).jstree($.extend(true, {},
    GNITE.Tree.ReferenceTree.configuration, {
      'json_data' : {
        'ajax' : {
          'url' : response.url
        }
      },
      'bookmarks' : {
        'viewer_form'   : '#bookmarks-results-' + tree_id,
        'addition_form' : '#bookmarks-addition-form-' + tree_id
      }
    }
  ));

  $('#tabs li:first-child ul li:last-child a').trigger('click');

  // Build the menu system for the new reference tree
  $('#container_for_' + response.domid).bind("init.jstree", function(event, data) {
    ddsmoothmenu.init({
      mainmenuid: "toolbar-reference-"+tree_id,
      orientation: 'h',
      classname: 'ddsmoothmenu',
      contentsource: "markup",
    });
  });

  // Bind bookmarks for the new reference tree
  $('#container_for_' + response.domid).bind('bookmarks_form.jstree', function(event, data) {
    $('#bookmarks-addition-form-' + tree_id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
  });

  $('#container_for_' + response.domid).bind('bookmarks_view.jstree', function(event, data) {
    GNITE.Tree.viewBookmarks(this);
  });

  $('#container_for_' + response.domid).bind('bookmarks_save.jstree', function(event, data) {
    var node = data.rslt;
    var id   = node.obj.attr('id');
    var title = $('#bookmark-title-' + tree_id).val();

    $.ajax({
      type        : 'POST',
      url         : '/reference_trees/' + tree_id + '/bookmarks',
      data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
      }
    });
  });

  GNITE.Tree.buildViewMenuActions();

  if (options) {
    options.spinnedElement.unspinner()
  }

};

GNITE.Tree.Node.getMetadata = function(url, container, wrapper) {
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
//    wrapper[0].scrollTop += nodePosition - visibleHeight + 36;
    }
  });
};


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

