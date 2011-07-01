/*global $, document, Juggernaut, ddsmoothmenu, setTimeout, window, alert */

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

/**************************************************************
         JUGGERNAUT
**************************************************************/
var jug = new Juggernaut();

jug.on("connect", function() { "use strict"; $('#master-tree').addClass("socket-active"); });
jug.on("disconnect", function() { "use strict"; $('#master-tree').removeClass("socket-active"); });


/********************************* jQuery START *********************************/
$(function() {

  "use strict";

  GNITE.Tree.MasterTree.id = $('.tree-container:first').attr('data-database-id');

  GNITE.Tree.MasterTree.channel = "tree_"+GNITE.Tree.MasterTree.id;

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
      'icons' : false
    },
    'html_data' : {
      'ajax' : {
        'data' : function(node) {
          if (node.attr) {
            $('#' + node.attr('id')).append("<span class=\"jstree-loading\">&nbsp;</span>");
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
      'select_limit' : -1
    },
    'plugins' : ['themes', 'html_data', 'ui', 'dnd', 'crrm', 'cookies', 'hotkeys']
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
            'icon'             : 'context-rename'
          },
          'create' : {
            'label'            : 'New child',
            'action'           : function(obj) { this.create(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-create'
          },
          'bulk-create' : {
            'label'            : 'New children',
            'action'           : function(obj) { this.bulk_form(obj); },
            'separator_after'  : true,
            'separator_before' : false,
            'icon'             : 'context-create-bulk'
          },
          'cut' : {
            'label'            : 'Cut',
            'action'           : function(obj) { this.cut(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-cut'
          },
          'paste' : {
            'label'            : 'Paste',
            'action'           : function(obj) { this.paste(obj); },
            'separator_after'  : false,
            'separator_before' : false,
            'icon'             : 'context-paste'
          },
          'refresh' : {
            'label'            : 'Refresh',
            'action'           : function(obj) { this.refresh(obj); },
            'separator_after'  : false,
            'separator_before' : true,
            'icon'             : 'context-refresh'
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
            'icon'             : 'context-delete'
          }
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
      'ctrl+shift+b' : function() { this.bookmarks_view(); },
      'ctrl+e'       : function() { if(this.data.ui.hovered || this._get_node(null)) { this.rename( this.data.ui.hovered || this._get_node(null) ); } else { return false; } },
      'ctrl+x'       : function() { this.cut( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+v'       : function() { this.paste( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+d'       : function() { this.remove( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+z'       : function() { this.undo(); },
      'ctrl+shift+z' : function() { this.redo(); },
      'ctrl+s'       : function() { GNITE.Tree.MasterTree.publish(); },
      'ctrl+h'       : function() { window.location = "/master_trees/" + GNITE.Tree.MasterTree.id + "/edits"; },
      'ctrl+m'       : function() { window.location = "/master_trees/" + GNITE.Tree.MasterTree.id + "/merge_events"; },
      'ctrl+c'       : function() { this.close_all(); }
    },
    'bookmarks' : {
      'addition_form' : '#bookmarks-addition-form-' + GNITE.Tree.MasterTree.id,
      'viewer_form'   : '#bookmarks-results-' + GNITE.Tree.MasterTree.id
    },
    'bulkcreate' : {
      'element' : '#bulkcreate-form'
    },
    'merge' : {
      'merge_form' : '#merge-form'
    },
    'ui' : {
      'select_limit' : -1,
      'select_multiple_modifier' : "ctrl"
    },
    'plugins' : ['themes', 'html_data', 'ui', 'dnd', 'crrm', 'cookies', 'contextmenu', 'bookmarks', 'hotkeys', 'bulkcreate', 'undoredo', 'merge']
  });

  GNITE.Tree.ReferenceTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
    'crrm' : {
      'move' : {
        'check_move' : function() { return false; }
      }
    },
    'ui' : {
      'select_limit' : -1,
      'select_multiple_modifier' : "on"
    },
    'plugins' : ['themes', 'html_data', 'ui', 'dnd', 'crrm', 'cookies', 'bookmarks', 'hotkeys']
  });

  GNITE.Tree.DeletedTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
    'crrm' : {
      'move' : {
        'check_move' : function() { return false; }
      }
    },
    'ui' : {
      'select_limit' : -1,
      'select_multiple_modifier' : "on"
    },
    'plugins' : ['themes', 'html_data', 'ui', 'dnd', 'crrm', 'cookies', 'hotkeys']
  });


  /*
   * Build the menu system for the master tree
   */
  ddsmoothmenu.init({
    mainmenuid: "toolbar",
    orientation: 'h',
    classname: 'ddsmoothmenu',
    contentsource: "markup"
  });

  /*
   * New Master Tree title input
   */
  $('#master_tree_title_input')
    .focus()
    .blur(function() {
      var self = $(this), title = "";

      if ($.trim(self.val()) === '') {
        setTimeout(function() {
          self.focus();
        }, 10);

        self.next().text('Please enter a title for your tree.').addClass('error');
      } else {
        title = self.val();

        $.post('/master_trees/' + GNITE.Tree.MasterTree.id, { 'master_tree[title]' : title, '_method' : 'put' }, function(response) {
          response = null;
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
      if (event.which === 13) {
        $(this).blur();
      }
    });

   /*
    * Hide the reference tree tabs
    */
   if ($('#reference-trees li').length === 0) {
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
      'html_data': {
        'ajax' : {
          'url'   : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes',
          'error' : function() {
            $('#master-tree').find("span.jstree-loading").remove();
          }
        }
      }
    }));
  }

  /*
   * Initialize Reference Trees when drop-down clicked
   */
  $('.reference-tree-container > div').each(function() {

    var self            = $(this), 
        tree_id         = self.attr('id').split('_')[4],
        active          = self.parents('.reference-tree').hasClass('reference-tree-active'),
        jugImporter = "";

    if (active) {
        $('#reference-trees li a').click(function() {
          if($(this).attr('href').split('_')[2] === tree_id && self.find('ul').length === 0) {
              // Render the reference tree
              self.jstree($.extend(true, {}, GNITE.Tree.ReferenceTree.configuration, {
                'html_data': {
                  'ajax' : {
                    'url' : '/reference_trees/' + tree_id + '/nodes',
                    'error' : function() {
                        self.find("span.jstree-loading").remove();
                      }
                  }
                },
                'bookmarks' : {
                    'viewer_form'   : '#bookmarks-results-' + tree_id,
                    'addition_form' : '#bookmarks-addition-form-' + tree_id
                }
              }));

              // Build the menu system for the reference tree
              self.bind("init.jstree", function(event, data) {
                event = null; data = null;
                ddsmoothmenu.init({
                  mainmenuid: "toolbar-reference-"+tree_id,
                  orientation: 'h',
                  classname: 'ddsmoothmenu',
                  contentsource: "markup"
                });
              });

              // Hide the spinner icon once node is loaded
              self.bind('open_node.jstree', function(event, data) {
                event = null;
                var node = data.rslt, id = node.obj.attr('id');
                $('#'+id).find("span.jstree-loading").remove();
              });

              self.bind('select_node.jstree', function(event, data) {
                event = null;
                var metadata = self.parent().next(),
                    wrapper  = self.parent(),
                    url      = '/reference_trees/' + tree_id + '/nodes/' + data.rslt.obj.attr("id");
                GNITE.Tree.Node.getMetadata(url, metadata, wrapper);
              });

              self.bind('bookmarks_form.jstree', function(event, data) {
                event = null;
                $('#bookmarks-addition-form-' + tree_id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
              });

              self.bind('bookmarks_view.jstree', function(event, data) {
                event = null; data = null;
                GNITE.Tree.viewBookmarks(this);
              });

              self.bind('bookmarks_save.jstree', function(event, data) {
                event = null;
                var node  = data.rslt,
                    id    = node.obj.attr('id'),
                    title = $('#bookmark-title-' + tree_id).val();

                $.ajax({
                  type        : 'POST',
                  url         : '/reference_trees/' + tree_id + '/bookmarks',
                  data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
                  contentType : 'application/json',
                  dataType    : 'json'
                });
              });

          }
        });

    } else {

      $('#toolbar-reference-' + tree_id + ' ul').hide();

      self.parent().spinner();
      self.parent().find(".spinner").append('<p class="status"></p>');

      jugImporter = new Juggernaut();
      jugImporter.on("connect", function() { self.parent().find(".status").addClass("juggernaut-connected"); });
      jugImporter.subscribe("tree_" + tree_id, function(data) {
        var response = $.parseJSON(data);
        switch(response.message) {
          case 'Import is successful':
            $.get('/reference_trees/' + tree_id + '.json', function(response, status, xhr) {
              status = null;
              if (xhr.status === 200) {
                self.parent().find(".status").addClass("juggernaut-complete");
                jugImporter.unsubscribe("tree_" + tree_id);
                self.parent().find(".status").html(response.message);
                self.parent().unspinner();
                GNITE.Tree.ReferenceTree.add(response);
                self.parents('.reference-tree').removeClass("reference-tree-importing").addClass("reference-tree-active");
                $('#toolbar-reference-' + tree_id + ' ul').show();
              }
            });
          break;

          default:
            self.parent().find(".status").html(response.message);
        }
      });

    }
  });

  /*
   * Initialize Deleted Names when tab clicked
   */
  $('.deleted-tree-container > div').each(function() {
    var self   = $(this),
        id     = self.attr('id').split('_')[4],
        active = self.parents('.deleted-tree').hasClass('deleted-tree-active');

    if (active) {
      $('#deleted a').click(function() {
        if(self.find('ul').length === 0) {
          // Render the deleted tree
          self.jstree($.extend(true, {}, GNITE.Tree.ReferenceTree.configuration, {
            'html_data': {
              'ajax' : {
                'url' : '/deleted_trees/' + id + '/nodes',
                'error' : function() {
                    self.find("span.jstree-loading").remove();
                }
              }
            }
          }));

          // Build the menu system for the deleted tree
          self.bind("init.jstree", function(event, data) {
            event = null; data = null;
            ddsmoothmenu.init({
              mainmenuid: "toolbar-deleted",
              orientation: 'h',
              classname: 'ddsmoothmenu',
              contentsource: "markup"
            });
          });

          // Hide the spinner icon once node is loaded
          self.bind('open_node.jstree', function(event, data) {
            event = null;
            var node = data.rslt, id = node.obj.attr('id');
            $('#'+id).find("span.jstree-loading").remove();
          });

        }
      });
    }

  });


  /**************************************************************
           JUGGERNAUT LISTENER
  **************************************************************/

  jug.subscribe(GNITE.Tree.MasterTree.channel, function(data) {
    var response = $.parseJSON(data);
    switch(response.subject) {
      case 'edit':
        GNITE.Tree.MasterTree.flashNode(response.action);
        $('.deleted-tree-container .jstree').jstree("refresh");
      break;

      case 'lock':
        $('#master-tree').jstree("lock");
      break;

      case 'unlock':
        $('#master-tree').jstree("unlock");
      break;

      case 'member-login':
        $("#chat-messages-head").effect("highlight", { color : "green" }, 2000);
        $("#chat-messages-list").prepend("<li class=\"new-user\"><span class=\"user\">" + response.user.email + "</span><span class=\"message\">arrived [" + response.time + "]</span></li>");
      break;

      case 'member-logout':
      break;

      case 'chat':
        $('#chat-messages-head').effect("highlight", { color : "green" }, 2000);
        $('#chat-messages-wrapper div').show();
        $('#chat-messages-list').prepend("<li class=\"chat\"><span class=\"user\">" + response.user.email + "</span>:<span class=\"message\">" + response.message + "</span></li>");
      break;
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
      var self = $(this),
          tree = self.parents('.tree-background').find('.jstree'),
          term = self.val().trim(),
          results = self.parents('.tree-background').find('.searchbar-results');

      if (term.length > 4) {

        results.spinner().show();

        $.ajax({
          url     : '/tree_searches/' + self.parents('.tree-background').find('.tree-container').attr('data-database-id') + '/' + term,
          type    : 'GET',
          data    : { },
          success : function(data) {
            results.html(data);
            results.find("a").click(function() {
               results.hide();
               tree.jstree("deselect_all");
               var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
               GNITE.Tree.openAncestry(tree, ancestry_arr);
               return false;
            });
          },
          error : function() {
          },
          complete : function() {
            results.unspinner();
          }
        });
      }
    })
    .live('keypress', function(event) {
      //enter key
      if (event.which === 13) {
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
  $('.nav-file-add').click(function() {
    $('#master-tree').jstree('create');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * FILE: Add many nodes
   */
  $('.nav-file-bulkadd').click(function() {
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
  $('.nav-file-publish').live('click', function() {
    GNITE.Tree.MasterTree.publish();
    return false;
  });

  /*
   * FILE: Delete tree
   */
  $('.nav-file-delete').live('click', function() {
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
                success     : function() {
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
    return false;
  });

  /*
   * EDIT: Undo
   */
  $('.nav-edit-undo').click(function() {
    $('#master-tree').jstree('undo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Redo
   */
  $('.nav-edit-redo').click(function() {
    //refresh affected parent(s) after redo
    $('#master-tree').jstree('redo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Rename node
   */
  $('.nav-edit-rename').click(function() {
    var selected = $('#master-tree').jstree("get_selected");
    if($('#master-tree').find("li").length > 0 && selected.length > 0) {
      $('#master-tree').jstree('rename');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Cut
   */
  $('.nav-edit-cut').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('cut');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Paste
   */
  $('.nav-edit-paste').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('paste');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Delete node
   */
  $('.nav-edit-delete').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('remove');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * TOOLS: Merge
   */
  $('.nav-tools-merge').click(function() {
    GNITE.Tree.MasterTree.merge();
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
    event = null;
    var self     = $(this),
        node     = data.rslt,
        name     = node.name,
        parentID = null;

    if (node.parent !== -1) {
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
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function(data) {
        node.obj.attr('id', data.node.id);
      }
    });
  });

  /*
   * ActionType: ActionBulkAddNode
   * Creates nodes in Master Tree
   */
  $('#master-tree').bind('bulk_form.jstree', function(event, data) {
    event = null;
    var node  = data.rslt,
        title = (typeof node.obj.attr("id") !== "undefined") ? $(node.obj).find("a:first").text() : 'Tree root';
    $("#bulkcreate-form").dialog("open");
    $('#bulkcreate-list').val("");
    $("#ui-dialog-title-bulkcreate-form").text(title);
  });

  $('#master-tree').bind('bulk_save.jstree', function(event, data) {
    event = null;
    var self      = $(this),
        node      = data.rslt,
        parent_id = (typeof node.obj.attr("id") !== "undefined") ? node.obj.attr("id") : GNITE.Tree.MasterTree.root,
        nodes     = $('#bulkcreate-list').val();

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'POST',
      async       : true,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'parent_id' : parent_id, 'name' : { 'name_string' : null } }, 'json_message' : { 'do' : nodes.split("\n") }, 'action_type' : "ActionBulkAddNode" }),
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function() {
        setTimeout(function checkLockedStatus() {
          if(self.find('ul:first').hasClass('jstree-locked')) {
            setTimeout(checkLockedStatus, 10);
          }
          else {
           if(typeof node.obj.attr("id") !== "undefined") {
             self.jstree("refresh", node.obj);
           }
           else {
             self.jstree("refresh");
           }
         }
        }, 10);
      }
    });

    setTimeout(function checkClosed() {
      if(node.obj.hasClass("jstree-closed")) {
        self.jstree("open_node", node.obj);
      }
      else {
        setTimeout(checkClosed, 10);
      }
    }, 10); 

  });

  $('#master-tree').bind('loaded.jstree', function(event, data) {
    event = null; data = null;
    $(this).addClass('loaded');
    // Lock the master tree if refreshed in midst of active job
    if(GNITE.Tree.MasterTree.state === "working") {
      $(this).jstree("lock");
    }
  });

  /*
   * ActionType: ActionRenameNode
   * Renames node in Master Tree
   */
  $('#master-tree').bind('rename.jstree', function(event, data) {
    event = null;

    var self     = $(this),
        node     = data.rslt,
        id       = node.obj.attr('id'),
        new_name = node.new_name;

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'PUT',
      async       : true,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + id + '.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : new_name } }, 'action_type' : 'ActionRenameNode' }),
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function(data) {
        node.obj.attr('id', data.node.id);
        GNITE.Tree.MasterTree.updateMetadataTitle(new_name);
      }
    });
  });

  /*
   * ActionType: ActionCopyNodeFromAnotherTree and ActionMoveNodeWithinTree
   * Moves node within Master Tree
   * TODO: if node was dragged from reference to master 2+ times, it will fail because of a duplicate key in nodes table on 'index_nodes_on_local_id_and_tree_id'
   * TODO: if a multi-select copy from reference to master, this should be a new action command model
   */
  $('#master-tree').bind('move_node.jstree', function(event, data) {
     event = null;

     var self        = $(this),
         result      = data.rslt,
         isCopy      = result.cy,
         parentID    = result.np.attr('id'),
         action_type = "";

     if (parentID === 'master-tree') {
       parentID = GNITE.Tree.MasterTree.root;
     }
    
     if (isCopy) {
       action_type = "ActionCopyNodeFromAnotherTree";
     } else {
       action_type = "ActionMoveNodeWithinTree";
     }

     // lock the tree
     self.jstree("lock");

     data.rslt.o.each(function() {

       var movedNodeID = $(this).attr("id"), url = '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes';

       if(!isCopy) { url += '/' + movedNodeID; }
       url += '.json';

       $.ajax({
           type        : isCopy ? 'POST' : 'PUT',
           async       : true,
           url         : url,
           data        : JSON.stringify({ 'node' : {'id' : movedNodeID, 'parent_id' : parentID }, 'action_type' : action_type }),
           contentType : 'application/json',
           dataType    : 'json',
           beforeSend  : function(xhr) {
             xhr.setRequestHeader("X-Session-ID", jug.sessionID);
           },
           success     : function(r) {
             if (isCopy) {
               // recommended data.rslt.oc.attr("id", r.node.id) not used because it applies same id to all new nodes in collection
               self.find('#copy_'+movedNodeID).attr("id", r.node.id);
             }
           }
        });
    });

  });

  /*
   * ActionType: ActionMoveNodeBetweenTrees
   * Moves node from Master Tree to Deleted Names & refreshes Deleted Names
   */
  $('#master-tree').bind('remove.jstree', function(event, data) {
    event = null;

    var self = $(this), node = data.rslt;

    // lock the tree
    self.jstree("lock");

    node.obj.each(function() {
      var id = $(this).attr('id');
      $.ajax({
        type        : 'PUT',
        async       : true,
        url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + id + '.json',
        data        : JSON.stringify({'action_type' : 'ActionMoveNodeToDeletedTree'}),
        contentType : 'application/json',
        dataType    : 'json',
        beforeSend  : function(xhr) {
          xhr.setRequestHeader("X-Session-ID", jug.sessionID);
        }
      });
    });

   // refresh the deleted tree
   $('.deleted-tree-container .jstree').jstree("refresh");

  });

  /*
  * Node metadata
  */
  $('#master-tree').bind('select_node.jstree', function(event, data) {
    event = null;

    var self     = $(this),
        metadata = self.parent().parent().next(),
        wrapper  = self.parent().parent(),
        url      = '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + data.rslt.obj.attr("id");

    GNITE.Tree.Node.getMetadata(url, metadata, wrapper);
  });

  /*
   * Double-click rename
   */
  $('#master-tree .jstree-clicked').live('dblclick', function() {
    $('.jstree-focused').jstree('rename');
  });

  $('#add-node-wrap').live('click', function(event) {

    var target = $(event.target);

    if (event.target.tagName !== 'A' && event.target.tagName !== 'INS') {
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
    event = null; data = null;

    var self = $(this);

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'GET',
      async       : true,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/undo',
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function(data) {
        GNITE.Tree.MasterTree.flashNode(data);
      }
    });

  });

  /*
   * Redo binding
   */
  $('#master-tree').bind('redo.jstree', function(event, data) {
    event = null; data = null;

    var self = $(this);

    // lock the tree
    self.jstree("lock");

    $.ajax({
      type        : 'GET',
      async       : true,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/redo',
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function(data) {
        if(data.status) {
          GNITE.pushMessage("perform", "unlock", false);
        }
        else {
          GNITE.Tree.MasterTree.flashNode(data);
        }
      }
    });

  });

  /*
   * Bookmark a node binding
   */
  $('#master-tree').bind('bookmarks_form.jstree', function(event, data) {
    event = null;
    $('#bookmarks-addition-form-' + GNITE.Tree.MasterTree.id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
  });

  $('#master-tree').bind('bookmarks_view.jstree', function(event, data) {
    event = null; data = null;
    GNITE.Tree.viewBookmarks(this);
  });

  $('#master-tree').bind('bookmarks_save.jstree', function(event, data) {
    event = null;

    var node  = data.rslt,
        id    = node.obj.attr('id'),
        title = $('#bookmark-title-' + GNITE.Tree.MasterTree.id).val();

    $.ajax({
      type        : 'POST',
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/bookmarks',
      data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
      contentType : 'application/json',
      dataType    : 'json'
    });

  });

  /*
   * Merge binding
   */
  $('#master-tree').bind('merge.jstree', function(event, data) {
    event = null; data = null;
    GNITE.Tree.MasterTree.merge();
  });

  $('#master-tree').bind('merge_submit.jstree', function(event, data) {
    event = null;
    
    if(data.rslt.obj) {
      $('#merge-form form').submit();
    }

  });

  /*
   * Hide the spinner icon after the node is loaded
   */
  $('#master-tree').bind('load_node.jstree', function(event, data) {
    event = null;

    var node = data.rslt;

    if(node.obj !== -1) { node.obj.find("span.jstree-loading").remove(); }
  });

  /*
   * Lock the tree
   */
  $('#master-tree').bind('lock.jstree', function(event, data) {
    event = null; data = null;
  });

  /*
   * Unlock the tree
   * NOTE: unlocking happens server->client via Juggernaut gem
   */
  $('#master-tree').bind('unlock.jstree', function(event, data) {
    event = null; data = null;
  });


  /**************************************************************
           SEARCH & IMPORT FROM GNACLR
  **************************************************************/
  $('#gnaclr-search')
    .live('blur', function() {
	
      var self = $(this), term = self.val().trim(), container = "";

      if (term.length > 0) {
        container = self.parents('.gnaclr-search').first();
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
              if ($(this).find('.count').text() !== '0') {
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
      if (event.which === 13) {
        $(this).blur();
      }
    });

  $('#browse-gnaclr, .ajax-load-new-tab, .gnaclr_classification_show').live('click', function() {
    $('#new-tab').load($(this).attr('href'));
    return false;
  });

  $('#import-gnaclr').live('click', function() {

    var self               = $(this),
        checkedRadioButton = $('#tree-revisions form input:checked'),
        opts               = { 
          master_tree_id   : GNITE.Tree.MasterTree.id,
          title            : checkedRadioButton.attr('data-tree-title'),
          url              : checkedRadioButton.attr('data-tree-url'),
          revision         : checkedRadioButton.attr('data-revision'),
          publication_date : checkedRadioButton.attr('data-publication-date'),
          spinnedElement   : $('#tree-newimport') 
        };

    $('#tree-newimport').spinner();
    self.remove();

    GNITE.Tree.importTree(opts);

    return false;
  });

  $('button.gnaclr-import').live('click', function() {

    var self = $(this),
        opts = { 
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

  $('.tabbed-header li').live('click', function() {
    $(this).parent().find('li').removeClass('active');
    $(this).addClass('active');

    $(this).parent().parent().find('.tabbed-panel').hide();
    $($(this).find('a').attr('href')).show();

    return false;
  });


  /**************************************************************
           IMPORT FLAT LIST
  **************************************************************/

  $('#import-roots-button').live('click', function() {

    var title      = $('#import-title').val().trim(),
        roots      = $('#import-roots').val().trim(),
        titleLabel = $('#import-title').parent().prev().find('label'),
        rootsLabel = $('#import-roots').parent().prev().find('label'),
        data       = "";

    if (title === '') {
      if (titleLabel.find('span').length === 0) {
        titleLabel.addClass('error').append('<span> is required.</span>');
      }
    } else {
      titleLabel.removeClass('error').find('span').remove();
    }

    if (roots === '') {
      if (rootsLabel.find('span').length === 0) {
        rootsLabel.addClass('error').append('<span> is required.</span>');
      }
    } else {
      rootsLabel.removeClass('error').find('span').remove();
    }

    if (title === '' || roots === '') {
      return false;
    }

    data = JSON.stringify({
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

  /**************************************************************
           CHAT
  **************************************************************/
  $('#chat-messages-head').click(function() {
    if($('#chat-messages-wrapper > div:not(:first)').is(':visible')) {
      $('#chat-messages-wrapper > div:not(:first)').hide();
      $('#chat-messages-maximize').show();
      $('#chat-messages-minimize').hide();
    } else {
      $('#chat-messages-wrapper > div:not(:first)').show();
      $('#chat-messages-maximize').hide();
      $('#chat-messages-minimize').show();
    }
  });
  $('#chat-messages-input').keypress(function(event) {
    if (event.which === 13) {
      GNITE.postChat();
      $(this).val('');
    }
  });

});

/********************************* jQuery END *********************************/


/**************************************************************
           HELPER FUNCTIONS
**************************************************************/
GNITE.pushMessage = function(subject, message, ignore) {

  "use strict";

  $.ajax({
    type        : 'PUT',
    async       : true,
    url         : '/push_messages/',
    contentType : 'application/json',
    dataType    : 'json',
    data        : JSON.stringify({ 'channel' : GNITE.Tree.MasterTree.channel, 'subject' : subject, 'message' : message }),
    beforeSend  : function(xhr) {
        if(ignore) { xhr.setRequestHeader("X-Session-ID", jug.sessionID); }
    }
  });
};

GNITE.postChat = function() {

  "use strict";

  var message = $('#chat-messages-input').val().trim();

  if(message) {
    GNITE.pushMessage("chat", message, false);
  }
};

GNITE.Tree.hideMenu = function() {

  "use strict";

  $('.toolbar>ul').find("ul").css({display:'none', visibility:'visible'});
};

GNITE.Tree.openAncestry = function(tree, obj) {

  "use strict";

  var _this         = this, 
      done          = true,
      end           = "",
      current       = [],
      remaining     = [],
      tree_wrapper  = tree.parents('#add-node-wrap, .reference-tree-container, .deleted-tree-container');

  if(obj.length) {
    $.each(obj, function (i, val) {
      i = null;
      if($(val).length && $(val).is(".jstree-closed")) {
        end = $(val);
        tree_wrapper.scrollTo($(val), {axis:'y'});
        current.push(val);
      }
      else if($(val).length && !$(val).is(".jstree-closed")) {
        end = $(val);
        tree_wrapper.scrollTo($(val), {axis:'y'});
      }
      else {
        remaining.push(val);
      }
    });
    if(remaining.length) {
      obj = remaining;
      $.each(current, function (i, val) {
        i = null;
        tree.jstree("open_node", val, function() {
          _this.openAncestry(tree, obj);
        });
      });
      done = false;
    }

    if(done) { tree.jstree("select_node", end); }
  }
};

GNITE.Tree.buildViewMenuActions = function() {

  "use strict";

  /*
  * VIEW: Refresh tree
  * Generic refresh action for any tree
  */
  $('.nav-view-refresh').click(function() {

    var self    = $(this),
        tree_id = self.parents('.tree-background').find('.jstree').attr("id");

    $('#'+tree_id).jstree('refresh');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * VIEW: Collapse tree
   * Generic collapse action for any tree
   */
  $('.nav-view-collapse').click(function() {

    var self    = $(this),
        tree_id = self.parents('.tree-background').find('.jstree').attr("id");

    $('#'+tree_id).jstree('close_all');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * BOOKMARKS: Add
   */
  $('.nav-bookmarks-add').click(function() {

    var self    = $(this),
        tree_id = self.parents('.tree-background').find('.jstree').attr("id");

    $('#'+tree_id).jstree('bookmarks_form');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * BOOKMARKS: View
   */
  $('.nav-bookmarks-view').click(function() {

    var self = $(this),
        tree_id = self.parents('.tree-background').find('.jstree').attr("id");

    $('#'+tree_id).jstree('bookmarks_view');
    GNITE.Tree.hideMenu();
    return false;
  });
};

GNITE.Tree.viewBookmarks = function(obj) {

  "use strict";

  var self      = $(obj),
      tree      = self.parents('.tree-background').find('.jstree'),
      tree_id   = tree.attr("id").split('_'),
      url       = (tree_id[0] === 'master-tree') ? '/master_trees/' + GNITE.Tree.MasterTree.id + '/bookmarks' : '/reference_trees/' + tree_id[4] + '/bookmarks',
      id        = (tree_id[0] === 'master-tree') ? GNITE.Tree.MasterTree.id : tree_id[4],
      bookmarks = $('#bookmarks-results-' + id),
      link      = "",
      edit      = "",
      del       = "",
      bookmark  = "",
      input     = "",
      val       = "";

  bookmarks.html("").spinner().dialog("open");

  $.ajax({
    url      : url,
    type     : 'GET',
    dataType : 'html',
    success  : function(data) {
      bookmarks.html(data);

      // Click a bookmark in list
      bookmarks.find("a.bookmarks-show").click(function() {
         tree.jstree("deselect_all");
         var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
         GNITE.Tree.openAncestry(tree, ancestry_arr);
         return false;
      });

      // Edit a bookmark in list
      bookmarks.find("a.bookmarks-edit").click(function() {

        //hide the link
        link = $(this).parent().parent().children("span:first");
        link.hide();

        //hide the edit link
        edit = $(this).parent();
        edit.hide();

        //hide the delete link
        del = edit.next();
        del.hide();

        bookmark = edit.prev();
        val = bookmark.text();

        input = $(this).parent().parent().children(".bookmarks-input");
        input.children("input").val(val);
        input.show();

        input.find(".bookmarks-save").click(function() {
          var newval = input.children("input").val();
          $.ajax({
            url   : url + '/' + $(this).attr("data-node-id"),
            type  : 'PUT',
            contentType : 'application/json',
            dataType    : 'json',
            data  : JSON.stringify({ 'bookmark_title' : newval }),
            success : function(data) {
              link.children("a").text(data.bookmark.bookmark_title);
              input.hide();
              link.show();
              edit.show();
              del.show();
            }
          });
          return false;
        });
        input.find(".bookmarks-cancel").click(function() {
          input.hide();
          link.show();
          edit.show();
          del.show();
          return false;
        });
        return false;
      });

      // Delete a bookmark in list
      bookmarks.find("a.bookmarks-delete").click(function() {
        var self = this;
        $.ajax({
          url   : url + '/' + $(self).attr("data-node-id"),
          type  : 'DELETE',
          success : function() {
            $(self).parent().parent().remove();
          }
        });
        return false;
      });

    },
    complete : function() {
      bookmarks.unspinner();
    }
  });

  GNITE.Tree.hideMenu();
  return false;
};

GNITE.Tree.importTree = function(opts) {

  "use strict";

  opts.spinnedElement.spinner();
  opts.spinnedElement.find(".spinner").append('<p class="status"></p>');

  var tree_id = "",
      data    = JSON.stringify({
        'master_tree_id'   : opts.master_tree_id,
        'title'            : opts.title,
        'url'              : opts.url,
        'revision'         : opts.revision,
        'publication_date' : opts.publication_date
      });

  $.ajax({
    type        : 'POST',
    async       : false,
    url         : '/gnaclr_imports',
    contentType : 'application/json',
    dataType    : 'json',
    data        : data,
    success     : function(response) {
      tree_id = response.tree_id;
    },
    error       : function() {
      opts.spinnedElement.unspinner();
      alert("Connection to the Global Names Classification and List Repository was lost. Import failed");
      return false;
    }
  });

  //see if the tree already exists and if not, initiate a juggernaut connection
  if(tree_id) {
    $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
      status = null;
      if (xhr.status === 200) {
        GNITE.Tree.ReferenceTree.add(response, opts);
      }
      else if (xhr.status === 204) {
        var jugImporter = new Juggernaut();
        jugImporter.on("connect", function() { opts.spinnedElement.find(".status").addClass("juggernaut-connected"); });
        jugImporter.subscribe("tree_" + tree_id, function(data) {
        var response = $.parseJSON(data);
        switch(response.message) {
          case 'Import is successful':
            $.get('/reference_trees/' + tree_id, { format : 'json' }, function(response, status, xhr) {
              status = null;
              if (xhr.status === 200) {
                opts.spinnedElement.find(".status").addClass("juggernaut-complete");
                jugImporter.unsubscribe("tree_" + tree_id);
                opts.spinnedElement.find(".status").html(response.message);
                GNITE.Tree.ReferenceTree.add(response, opts);
              }
            });
            break;

            default:
              opts.spinnedElement.find(".status").html(response.message);
          }
        });
      }
    });
  }

  return false;
};

GNITE.Tree.MasterTree.publish = function() {

  "use strict";

  $.ajax({
    type        : 'GET',
    url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/publish.json',
    contentType : 'application/json',
    dataType    : 'json',
    success     : function() {
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

  "use strict";

  var self               = $('#master-tree'),
      destination_parent = self.find('#'+data.destination_parent_id),
      source_parent      = self.find('#' + data.parent_id),
      selected           = self.jstree("get_selected");

  setTimeout(function checkLockedStatus() {
    if(self.find('ul:first').hasClass('jstree-locked')) {
      setTimeout(checkLockedStatus, 10);
    }
    else {
      //Adjust the Metadata Title if node is selected and the action was an undo or a redo of a rename
      if(data.new_name !== data.old_name && $(selected[0]).attr("id") === data.node_id.toString()) {
        if(data.undo) {
          GNITE.Tree.MasterTree.updateMetadataTitle(data.old_name);
        }
        else {
          GNITE.Tree.MasterTree.updateMetadataTitle(data.new_name);
        }
      }
      if(data.parent_id.toString() === GNITE.Tree.MasterTree.root) {
        self.jstree("refresh");
      }
      else {
        if(data.destination_parent_id && destination_parent.length > 0) {
          self.jstree("refresh", $('#'+data.destination_parent_id));
          self.find('#' + data.destination_parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
        }
        if(data.destination_parent_id !== data.parent_id && source_parent.length > 0) {
          self.jstree("refresh", $('#'+data.parent_id));
          self.find('#' + data.parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
        }
      }
    }
  }, 10);
};

GNITE.Tree.MasterTree.updateMetadataTitle = function(name) {

  "use strict";

  $('#treewrap-main .node-metadata span.ui-dialog-title').text(name);
};

GNITE.Tree.MasterTree.merge = function() {

  "use strict";

  var master                    = $('#master-tree'),
      master_selected           = master.jstree("get_selected"),
      reference                 = $('.reference-tree-container div.jstree-focused'),
      reference_selected        = reference.jstree("get_selected"),
      master_selected_string    = "",
      reference_selected_string = "",
      message                   = "";

  if(master_selected.length === 0 || master_selected.legnth > 1 || reference_selected.length > 1 || reference_selected.length === 0) {
    message = '<p>Select one name in your working tree and one name in your reference tree then re-execute merge.</p>';
    $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Merge Instructions">' + message + '</div>');
    $('#dialog-message').dialog({
        height : 200,
        width : 500,
        modal : true,
        closeText : "",
        buttons: [
         {
           className : "green-submit",
           text : "OK",
           click : function() {
             $('#dialog-message').dialog("destroy").hide().remove();
           }
         }
       ],
       draggable : false,
       resizable : false
    });
  }
  else {
    master_selected_string = master.jstree("get_text", $('#'+master_selected[0].id));
    reference_selected_string = reference.jstree("get_text", $('#'+reference_selected[0].id));

    $('#master-tree-merge-selection h2').text($('#header h1').text());
    $('#reference-tree-merge-selection h2').text(reference.parents('.reference-tree').find('.breadcrumbs ul li').text());

    $('#master-tree-merge-selection span').text(master_selected_string).parent().find("input").val(master_selected[0].id);
    $('#reference-tree-merge-selection span').text(reference_selected_string).parent().find("input").val(reference_selected[0].id);

    $("#merge-form").dialog("open");
  }

  return false;
};

GNITE.Tree.ReferenceTree.add = function(response, options) {

  "use strict";

  var tab     = "",
      tree_id = "",
      self    = "",
      count   = "";

  if ($('a[href="#' + response.domid + '"]').length !== 0 && $('#' + response.domid).hasClass("reference-tree-active")) {
    $('#tabs li:first-child ul li a[href="#' + response.domid +'"]').trigger('click');
  }
  else {
    if($('a[href="#' + response.domid + '"]').length === 0) {

      tab = $('#all-tabs');
      count = parseInt(tab.text().replace(/[^0-9]+/, ''), 10);

      tab.text('All reference trees (' + (count + 1) + ')');

      $('#new-tab').before(response.tree);

      $('#tab-titles li:first-child').show();
      $('#reference-trees').append('<li><a href="#' + response.domid + '">' + response.title + '</a></li>');
    }

    tree_id = response.domid.split('_')[2];
    self = $('#container_for_' + response.domid);

    self.jstree($.extend(true, {},
      GNITE.Tree.ReferenceTree.configuration, {
        'html_data': {
          'ajax' : {
            'url' : response.url,
            'error' : function() {
              self.find("span.jstree-loading").remove();
            }
          }
        },
        'bookmarks' : {
          'viewer_form'   : '#bookmarks-results-' + tree_id,
          'addition_form' : '#bookmarks-addition-form-' + tree_id
        }
      }
    ));

    // Build the menu system for the new reference tree
    self.bind("init.jstree", function(event, data) {
      event = null; data = null;
      ddsmoothmenu.init({
        mainmenuid: "toolbar-reference-"+tree_id,
        orientation: 'h',
        classname: 'ddsmoothmenu',
        contentsource: "markup"
      });
    });

    // hide the spinner icon once node is loaded
    self.bind('open_node.jstree', function(event, data) {
      event = null;

      var node = data.rslt, id = node.obj.attr('id');
      $('#'+id).find("span.jstree-loading").remove();
    });

    self.bind('select_node.jstree', function(event, data) {
      event = null;

      var metadata = self.parent().next(),
          wrapper  = self.parent(),
          url      = '/reference_trees/' + tree_id + '/nodes/' + data.rslt.obj.attr("id");

      GNITE.Tree.Node.getMetadata(url, metadata, wrapper);
    });

    // Bind bookmarks for the new reference tree
    self.bind('bookmarks_form.jstree', function(event, data) {
      event = null;
      $('#bookmarks-addition-form-' + tree_id).dialog("option", "title", "Bookmark " + $('#' + data.rslt.obj.attr('id') + ' a:first').text()).dialog("open");
    });

    self.bind('bookmarks_view.jstree', function(event, data) {
      event = null; data = null;
      GNITE.Tree.viewBookmarks(this);
    });

    self.bind('bookmarks_save.jstree', function(event, data) {
      event = null;

      var node  = data.rslt,
          id    = node.obj.attr('id'),
          title = $('#bookmark-title-' + tree_id).val();

      $.ajax({
        type        : 'POST',
        url         : '/reference_trees/' + tree_id + '/bookmarks',
        data        : JSON.stringify({ 'id' : id, 'bookmark_title' : title }),
        contentType : 'application/json',
        dataType    : 'json'
      });
    });

    GNITE.Tree.buildViewMenuActions();

    $('#' + response.domid).siblings('.ui-tabs-nav').children('.ui-state-default').removeClass('ui-tabs-selected ui-state-active');
    $('#' + response.domid).removeClass("ui-tabs-hide").siblings('.ui-tabs-panel').addClass("ui-tabs-hide");

  }

  if (options) {
    options.spinnedElement.unspinner();
  }

};

GNITE.Tree.Node.getMetadata = function(url, container, wrapper) {

  "use strict";

  container.spinner();

  $.ajax({
    type        : 'GET',
    url         : url,
    contentType : 'text/html',
    dataType    : 'html',
    success     : function(data) {
      container.html(data);
      wrapper.css('bottom', container.height());
      container.find(".ui-icon").click(function() {
        container.hide();
        wrapper.css('bottom', '20px');
        return false;
      });
    }
  });

  container.unspinner().show();
  wrapper.css('bottom', container.height());
};
