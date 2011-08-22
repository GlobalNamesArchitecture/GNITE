/*global $, document, Juggernaut, ddsmoothmenu, setTimeout, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = {
  Tree : {
    MasterTree    : {},
    DeletedTree   : {},
    ReferenceTree : {},
    Node          : {}
  }
};

/**************************************************************
         JUGGERNAUT
**************************************************************/
var jug = new Juggernaut();

/********************************* jQuery START *********************************/
$(function() {

  "use strict";

  jug.on("connect", function() { "use strict"; $('#master-tree').addClass("socket-active"); });
  jug.on("disconnect", function() { "use strict"; $('#master-tree').removeClass("socket-active"); });

  GNITE.Tree.MasterTree.id = $('.tree-container:first').attr('data-database-id');

  GNITE.Tree.MasterTree.channel = "tree_" + GNITE.Tree.MasterTree.id;

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
          'chat' : {
            'label'            : 'Send link to chat',
            'action'           : function(obj) { GNITE.nodeMessage(obj); },
            'separator_after'  : true,
            'separator_before' : false,
            'icon'             : 'context-chat'
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
      'ctrl+h'       : function() {
        var url   = "/master_trees/" + GNITE.Tree.MasterTree.id + "/edits",
            input = '<input type="hidden" name="" value="" />';
        jQuery('<form action="'+ url +'" method="GET">'+input+'</form>').appendTo('body').submit().remove();
      },
      'ctrl+m'       : function() {
        var url   = "/master_trees/" + GNITE.Tree.MasterTree.id + "/merge_events",
            input = '<input type="hidden" name="" value="" />';
       jQuery('<form action="'+ url +'" method="GET">'+input+'</form>').appendTo('body').submit().remove(); 
      },
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
      'select_limit' : 1
    },
    'dnd' : {
      'drag_check' : function() {
        return { 
          after  : false, 
          before : false, 
          inside : true 
        };
      },
      'drag_finish' : function(data) {
        GNITE.Tree.MasterTree.externalDragged(data);
      },
      'drop_check': function(data) {
        var response = true;

        if(data.o.attr("id") == $(".node-metadata .ui-dialog-titlebar").attr("data-node-id")) { response = false; }
        if(!data.o.hasClass("jstree-leaf")) { response = false; }

        return response;
      },
      'drop_finish' : function(data) {
        GNITE.Tree.MasterTree.externalDropped(data);
      }
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
    'dnd' : {
      'drag_check' : function() {
        return false;
      },
      'drag_finish' : function(data) {
        GNITE.Tree.MasterTree.externalDragged(data);
      },
      'drop_check' : function(data) {
        var response = true;
        data.o.each(function() {
          if(!$(this).hasClass("jstree-leaf")) { response = false; }
        });
        return response;
      }, 
      'drop_finish' : function(data) {
        GNITE.Tree.MasterTree.externalDropped(data);
      }
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
    'dnd' : {
      'drag_check' : function() {
        return false;
      },
      'drop_check' : function() {
        return false;
      },
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
    contentsource: 'markup'
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

              self.bind('loaded.jstree', function(event, data) {
                event = null; data = null;
                self.addClass('loaded');
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

              self.bind('deselect_all.jstree', function() {
                self.parent().next().hide();
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

          self.bind('loaded.jstree', function(event, data) {
            event = null; data = null;
            self.addClass('loaded');
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
  $('#toolbar .nav-file-add').click(function() {
    $('#master-tree').jstree('create');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * FILE: Add many nodes
   */
  $('#toolbar .nav-file-bulkadd').click(function() {
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
  $('#toolbar .nav-file-publish').live('click', function() {
    GNITE.Tree.MasterTree.publish();
    return false;
  });

  /*
   * FILE: Delete tree
   */
  $('#toolbar .nav-file-delete').live('click', function() {
    var message = 'Are you sure you want to delete your working tree?';
    $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Delete Confirmation">' + message + '</div>');
    $('#dialog-message').dialog({
        height : 200,
        width : 500,
        modal : true,
        closeText : "",
        buttons: [
          {
            'class' : "green-submit",
            text  : "Delete",
            click : function() {
              var formData = $("form").serialize();
              $.ajax({
                type        : 'DELETE',
                url         :  '/master_trees/' + GNITE.Tree.MasterTree.id,
                data        :  formData,
                success     : function() {
                  var url   = "/master_trees",
                      input = '<input type="hidden" name="" value="" />';
                  jQuery('<form action="'+ url +'" method="GET">'+input+'</form>').appendTo('body').submit().remove();
                }
              });
           }
         },
         {
           'class' : "cancel-button",
           text  : "Cancel",
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
  $('#toolbar .nav-edit-undo').click(function() {
    $('#master-tree').jstree('undo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Redo
   */
  $('#toolbar .nav-edit-redo').click(function() {
    //refresh affected parent(s) after redo
    $('#master-tree').jstree('redo');
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Rename node
   */
  $('#toolbar .nav-edit-rename').click(function() {
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
  $('#toolbar .nav-edit-cut').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('cut');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Paste
   */
  $('#toolbar .nav-edit-paste').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('paste');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * EDIT: Delete node
   */
  $('#toolbar .nav-edit-delete').click(function() {
    if($('#master-tree').find("li").length > 0) {
      $('#master-tree').jstree('remove');
    }
    GNITE.Tree.hideMenu();
    return false;
  });

  /*
   * TOOLS: Merge
   */
  $('#toolbar .nav-tools-merge').click(function() {
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
          } else {
           if(typeof node.obj.attr("id") !== "undefined") {
             self.jstree("refresh", node.obj);
           } else {
             self.jstree("refresh");
           }
         }
        }, 10);
      }
    });

    setTimeout(function checkClosed() {
      if(node.obj.hasClass("jstree-closed")) {
        self.jstree("open_node", node.obj);
      } else {
        setTimeout(checkClosed, 10);
      }
    }, 10); 

  });

  $('#master-tree').bind('loaded.jstree', function(event, data) {
    event = null; data = null;
    $(this).addClass('loaded');
    // Lock the master tree if refreshed in midst of active job
    if(GNITE.Tree.MasterTree.state === "working" || GNITE.Tree.MasterTree.state === "merging") {
      $(this).jstree("lock");
    }
    if(GNITE.Tree.MasterTree.state === "merging") {
      GNITE.Tree.MasterTree.showMergeWarning();
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
   * ActionType: ActionCopyNodeFromAnotherTree, ActionBulkCopyNode and ActionMoveNodeWithinTree
   * Moves node within Master Tree or copies from Reference Tree to Master Tree
   */
  $('#master-tree').bind('move_node.jstree', function(event, data) {
     event = null;

     var self               = $(this),
         result             = data.rslt,
         isCopy             = result.cy,
         parentID           = result.np.attr('id'),
         action_type        = "",
         reference          = $(".reference-tree:not('.ui-tabs-hide') div.jstree"),
         reference_selected = reference.jstree("get_selected"),
         deleted            = $(".deleted-tree:not('.ui-tabs-hide') div.jstree"),
         deleted_selected   = deleted.jstree("get_selected"),
         do_ids             = [],
         url                = '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes',
         movedNodeID        = "";

     if (parentID === 'master-tree') {
       parentID = GNITE.Tree.MasterTree.root;
     }
    
     if (isCopy) {
       action_type = "ActionCopyNodeFromAnotherTree";
       if(reference_selected.length > 1) {
         action_type = "ActionBulkCopyNode";
         data.rslt.o.each(function() {
           do_ids.push(this.id);
         });
       }
       if(deleted_selected.length > 1) {
         action_type = "ActionBulkCopyNode";
         data.rslt.o.each(function() {
           do_ids.push(this.id);
         });
       }
     } else {
       action_type = "ActionMoveNodeWithinTree";
     }

     movedNodeID = data.rslt.o[0].id;
     if(!isCopy) { url += '/' + movedNodeID; }
     url += '.json';

     // lock the tree
     self.jstree("lock");

     $.ajax({
       type        : isCopy ? 'POST' : 'PUT',
       async       : true,
       url         : url,
       data        : JSON.stringify({ 'node' : {'id' : movedNodeID, 'parent_id' : parentID }, 'json_message' : { 'do' : do_ids }, 'action_type' : action_type }),
       contentType : 'application/json',
       dataType    : 'json',
       beforeSend  : function(xhr) {
         xhr.setRequestHeader("X-Session-ID", jug.sessionID);
       },
       success     : function(r) {
         var i = 0;

         if (isCopy && do_ids.length === 0) {
           // recommended data.rslt.oc.attr("id", r.node.id) not used because it applies same id to all new nodes in collection
           self.find('#copy_'+movedNodeID).attr("id", r.node.id);
         } else if (isCopy && do_ids.length > 0) {
           for(i = 0; i < r.do.length; i += 1) {
             self.find('#copy_' + r.do[i]).attr("id", r.undo[i])
           }
         } 
       }
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

  $('#master-tree').bind('deselect_all.jstree', function() {
    $(this).parent().parent().next().hide();
  });

  /*
   * Double-click rename
   */
  $('#master-tree .jstree-clicked').live('dblclick', function() {
    $('.jstree-focused').jstree('rename');
  });

  /*
   * Deselect nodes
   */
  $('#add-node-wrap').live('click', function(event) {

    var target = $(event.target);

    if (event.target.tagName !== 'A' && event.target.tagName !== 'INS') {
      $('#add-node-wrap').css('bottom', '20px');
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
        } else {
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
      data = JSON.stringify({ 
        "merge" : {
          "master_tree_node"    : $('#merge_master_tree_node').val(), 
          "reference_tree_node" : $('#merge_reference_tree_node').val(),
          "authoritative_node"  : $('input[name="merge[authoritative_node]"]:checked').val()
        }
      });
      $(".ui-dialog-buttonpane").hide();
      $(".ui-dialog-titlebar-close").hide();
      $('#merge-form').spinner().find(".spinner").append('<p class="status">Starting merge...</p>');
      $.ajax({
        url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/merge_events',
        type        : 'POST',
        data        : data,
        contentType : 'application/json',
        success     : function(response) {
          var url = $('#merge-view-results a').attr("href");
          $('#merge-view-results a').attr("href", url + "/" + response.merge_event);
        }
      });
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
  $('#chat-messages-head').click(function() { GNITE.toggleChatWindow(); });
  $('#chat-messages-options a').click(function() { GNITE.toggleChatWindow(); return false; });

  $('#chat-messages-input').keypress(function(e) {
    var msg  = $(this).val().replace("\n", ""),
        code = (e.keyCode ? e.keyCode : e.which);
 
    if(code !== 13) { return; }
    if (!$.isBlank(msg)) {
      GNITE.pushMessage("chat", msg, false);
      $(this).val("");
    }
    return false;
  });

  /**************************************************************
           JUGGERNAUT LISTENER
  **************************************************************/
  jug.subscribe(GNITE.Tree.MasterTree.channel, function(data) {
    var response = $.parseJSON(data), self = $('#master-tree');
    switch(response.subject) {

      case 'edit':
        GNITE.Tree.MasterTree.flashNode(response.action);
        $('.deleted-tree-container .jstree').jstree("refresh");
      break;

      case 'merge':
        self.jstree("lock");
        GNITE.Tree.MasterTree.showMergeWarning(response.merge_id);
      break;

      case 'MergeEvent':
        $(".spinner").find(".status").html(response.message);
        if(response.message === "Merging is complete") {
          $(".spinner").css("background-image", "none").find(".status").html(response.message).addClass("merge-complete");
          $("#merge-view-results").show();
        }
      break;

      case 'lock':
        self.jstree("lock");
      break;

      case 'unlock':
        self.jstree("unlock");
      break;

      case 'member-login':
        GNITE.flashChatWindow();
        GNITE.appendMessage("new-user", response);
      break;

      case 'member-logout':
      break;

      case 'chat':
        GNITE.flashChatWindow();
        GNITE.appendMessage("chat", response);
      break;

      case 'log':
        if(GNITE.Tree.MasterTree.user_id !== response.user.id.toString()) { GNITE.flashChatWindow(); }
        GNITE.appendMessage("log", response);
      break;

      case 'metadata':
        GNITE.Tree.MasterTree.refreshMetadata(response.action.node_id);
      break;
    }
  });

});

/********************************* jQuery END *********************************/


/**************************************************************
           HELPER FUNCTIONS
**************************************************************/
GNITE.toggleChatWindow = function() {
  if($('#chat-messages-wrapper > div:not(:first)').is(':visible')) {
    $('#chat-messages-wrapper > div:not(:first)').hide();
    $('#chat-messages-maximize').show();
    $('#chat-messages-minimize').hide();
  } else {
    $('#chat-messages-wrapper > div:not(:first)').show();
    $('#chat-messages-maximize').hide();
    $('#chat-messages-minimize').show();
  }
};

GNITE.flashChatWindow = function() {
  $('#chat-messages-head').effect("highlight", { color : "green" }, 2000);
  $('#chat-messages-maximize').hide();
  $('#chat-messages-minimize').show();
  $('#chat-messages-wrapper div').show();
};

GNITE.appendMessage = function(type, response) {
  var message = response.message;

  switch(type) {
    case 'new-user':
      message = "<strong>arrived</strong> [" + response.time + "]";
    break;
    case 'log':
      message = "<strong>edited</strong> [" + response.time + "]</span><span class=\"message\">" + response.message;
    break;
  }

  $('#chat-messages-list').append("<li class=\"" + type + "\"><span class=\"user\">" + response.user.email + "</span>:<span class=\"message\">" + message + "</span></li>").parent().scrollTo('li:last',500);

  $("#chat-messages-list a[data-path]").click(function() {
    var self          = $('#master-tree'),
        ancestry_arr  = $(this).attr("data-path").split(","),
        ancestry_arr2 = [];

    $.each(ancestry_arr, function(i, val) {
      ancestry_arr2.push('#' + val);
    });
    self.jstree("deselect_all");
    GNITE.Tree.openAncestry(self, ancestry_arr2);
    return false;
  });
};

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

GNITE.nodeMessage = function(obj) {
  var self        = $('#master-tree');
      path        = self.jstree("get_path", obj, true),
      node_string = self.jstree("get_text", obj);

  GNITE.flashChatWindow();
  
  $('#chat-messages-input').val("<a href=\"#\" data-path=\"" + path + "\">" + node_string + "</a>");
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
      } else if($(val).length && !$(val).is(".jstree-closed")) {
        end = $(val);
        tree_wrapper.scrollTo($(val), {axis:'y'});
      } else {
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
  * VIEW: Deselect all nodes
  */
  $('.nav-view-deselectall').click(function() {

    var self    = $(this),
        tree_id = self.parents('.tree-background').find('.jstree').attr("id");

    $('#'+tree_id).jstree('deselect_all');
    GNITE.Tree.hideMenu();
    return false;
  });

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

  bookmarks.html("");
  bookmarks.spinner().dialog("open");

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
      } else if (xhr.status === 204) {
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
            'class' : "green-submit",
            text  : "OK",
            click : function() { $(this).dialog("close"); }
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
    } else {
      //update metadata title if node is selected and the action was an undo or a redo of a rename
      if(data.new_name !== data.old_name && data.node_id && $(selected[0]).attr("id") === data.node_id.toString()) {
        if(data.undo) {
          GNITE.Tree.MasterTree.updateMetadataTitle(data.old_name);
        } else {
          GNITE.Tree.MasterTree.updateMetadataTitle(data.new_name);
        }
      }
      if(data.parent_id.toString() === GNITE.Tree.MasterTree.root) {
        self.jstree("refresh");
      } else {
        if(data.destination_parent_id && destination_parent.length > 0) {
          self.jstree("refresh", $('#' + data.destination_parent_id));
          setTimeout(function checkVisible() {
            if($('#' + data.destination_parent_id).length === 0) {
              setTimeout(checkVisible, 10);
            } else {
              $('#' + data.destination_parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
            }
          }, 10);
        }
        if(data.destination_parent_id !== data.parent_id && source_parent.length > 0) {
          self.jstree("refresh", $('#' + data.parent_id));
          setTimeout(function checkVisible() {
            if($('#' + data.parent_id).length === 0) {
              setTimeout(checkVisible, 10);
            } else {
              $('#' + data.parent_id + ' a:first').effect("highlight", { color : "#BABFC3" }, 2000);
            }
          }, 10);
        }
      }
    }
  }, 10);
};

GNITE.Tree.MasterTree.updateMetadataTitle = function(name) {

  "use strict";

  $('#treewrap-main .node-metadata span.ui-dialog-title').text(name);
};

GNITE.Tree.MasterTree.showMergeWarning = function(merge_id) {

  "use strict";

  $('#toolbar .topnav').hide();
  if(merge_id) { $('#merge-warning a').attr("href", "/master_trees/" + GNITE.Tree.MasterTree.id + "/merge_events/" + merge_id); }
  $('#merge-warning').show();
};

GNITE.Tree.MasterTree.merge = function() {

  "use strict";

  var master                    = $('#master-tree'),
      master_selected           = master.jstree("get_selected"),
      reference                 = $(".reference-tree:not('.ui-tabs-hide') div.jstree"),
      reference_selected        = reference.jstree("get_selected"),
      master_selected_string    = "",
      reference_selected_string = "",
      message                   = "";

  if(master_selected.length === 0 || master_selected.length > 1 || reference_selected.length > 1 || reference_selected.length === 0) {
    message = '<p>Select one name in your working tree and one name in your reference tree then re-execute merge.</p>';
    $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Merge Instructions">' + message + '</div>');
    $('#dialog-message').dialog({
        height : 200,
        width : 500,
        modal : true,
        closeText : "",
        buttons: [
         {
           'class' : "green-submit",
           text  : "OK",
           click : function() {
             $('#dialog-message').dialog("destroy").remove();
           }
         }
       ],
       draggable : false,
       resizable : false
    });
  } else {
    master_selected_string = master.jstree("get_text", $('#'+master_selected[0].id));
    reference_selected_string = reference.jstree("get_text", $('#'+reference_selected[0].id));

    $('#master-tree-merge-selection h2').text($('#header h1').text());
    $('#reference-tree-merge-selection h2').text(reference.parents('.reference-tree').find('.breadcrumbs ul li').text());

    $('#master-tree-merge-selection label').text(master_selected_string).parent().find("input").val(master_selected[0].id);
    $('#reference-tree-merge-selection label').text(reference_selected_string).parent().find("input").val(reference_selected[0].id);

    $("#merge-form").dialog("open");
  }

  return false;
};

/*
  DRAG ITEM FROM METADATA PANEL INTO TREE - COMMENTED OUT UNTIL BELOW ACCOMMODATED

  TODO:
    1. check if drag from master synonym into master tree (i.e. synonym elevated to valid)
       - synonym needs to be removed and metadata panel refreshed
       - parent node needs to be refreshed
       - Undo/redo? Does not fit the action_type paradigm because a valid/synonym needs to be toggled
    2. check if drag from reference (or deleted) metadata panel into master metadata panel (i.e. new synonym created)
       - metadata panel needs to be refreshed
       - Undo/redo works fine
    3. To implement: jstree-dragged class needs to be added to li elements in metadata panel in _metadata.html.erb view
    4. Use juggernaut to refresh the metadata panel
*/
GNITE.Tree.MasterTree.externalDragged = function(data) {
/*
  "use strict";

  var self     = $('#master-tree'),
      foreign  = data.o,
      node     = data.r,
      parentID = node.attr('id'),
      name     = $(foreign).text();

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
    success     : function() {
      self.jstree("refresh", $('#'+parentID));
    }
  });
*/
};

GNITE.Tree.MasterTree.externalDropped = function(data) {

  "use strict";

  var self        = $('#master-tree'),
      node        = data.o,
      node_parent = node.parent().parent(),
      name_string = self.jstree("get_text", node),
      dest        = self.find(".jstree-clicked").parent("li"),
      dest_parent = dest.parent().parent(),
      type        = data.r.attr("data-type"),
      metadata    = self.parents(".tree-background").find(".node-metadata");

  if($('#' + node.attr("id")).parents().is("#master-tree")) {
    $.ajax({
      type        : 'POST',
      async       : false,
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'id' : node.attr("id"), 'destination_node_id' : dest.attr("id"), 'destination_parent_id' : dest_parent.attr("id") }, 'json_message' : { }, 'action_type' : "ActionNodeToSynonym" }),
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-Session-ID", jug.sessionID);
      },
      success     : function(data) {
        if(node_parent.length > 0) { self.jstree("refresh", node_parent); }
        if(dest_parent.length > 0) { self.jstree("refresh", dest_parent); }
        if(node_parent.length > 0 && dest_parent.length > 0) {
          setTimeout(function checkVisible() {
            if($('#' + data.undo.merged_node_id).length === 0) {
              setTimeout(checkVisible, 10);
            } else {
              self.jstree("select_node", $('#' + data.undo.merged_node_id));
            }
          }, 10);
        }
      }
    });
  } else {
    data.o.each(function() {
      name_string = $('#' + node.attr("id")).parents(".jstree").jstree("get_text", $(this));
      GNITE.Tree.MasterTree.reconciliation({
        type           : type,
        action         : 'POST',
        destination_id : dest.attr("id"),
        data           : {
          name_string    : name_string
        }
      });
    });
  }
};

GNITE.Tree.ReferenceTree.add = function(response, options) {

  "use strict";

  var tab     = "",
      tree_id = "",
      self    = "",
      count   = "";

  if ($('a[href="#' + response.domid + '"]').length !== 0 && $('#' + response.domid).hasClass("reference-tree-active")) {
    $('#tabs li:first-child ul li a[href="#' + response.domid +'"]').trigger('click');
  } else {
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

    self.bind('deselect_all.jstree', function() {
      self.parent().next().hide();
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
      if(wrapper.find("#master-tree").length) {
        GNITE.Tree.Node.adjustMasterTreeMetadata(container);
      }
      wrapper.css('bottom', container.height());
    }
  });

  container.unspinner().show();

};

GNITE.Tree.Node.adjustMasterTreeMetadata = function(container) {

  "use strict";

  var selected = $('#master-tree').jstree('get_selected'),
      node_id  = $(selected[0]).attr("id");

  $('.metadata-autocomplete').inlineComplete();

  $(".metadata-section").find(".ddsmoothmenu").each(function() {
    ddsmoothmenu.init({
      mainmenuid: $(this).attr("id"),
      orientation: 'h',
      classname: 'ddsmoothmenu',
      contentsource: "markup"
    });
  });

  container.find("li.rank, li.synonym, li.vernacular, li.metadata-add").each(function() {
    var self = $(this), type = self.parent().parent().attr("data-type");

    $(this).not('.metadata-add').click(function() { return false; });

    if(self.hasClass("synonym") || self.hasClass("vernacular")) {
      self.contextMenu(self.attr("class") + '-context', {
        'bindings' : {
          'nav-edit-rename' : function(t) {
            GNITE.Tree.MasterTree.editMetadata(self, type, "PUT");
           },
           'nav-edit-delete' : function(t) {
             container.spinner();
             GNITE.Tree.MasterTree.reconciliation({ 
               type           : type, 
               action         : 'DELETE', 
               id             : self.attr("id").split("-")[1],
               destination_id : node_id,
               data           : {
                 name_string    : self.find("a span").text(),
               }
             });
             container.unspinner();
           }
         },
         'onContextMenu' : function() { self.find('ul.subnav').hide(); return true; }
       }).find("a:first").dblclick(function() {
         $(this).unbind('dblclick');
         if(self.hasClass("metadata-none")) {
           GNITE.Tree.MasterTree.editMetadata(self, type, "POST");
         } else {
           GNITE.Tree.MasterTree.editMetadata(self, type, "PUT");
         }
       });

       self.find("ul.subnav li a").click(function() {
         GNITE.Tree.Node.updateMetadata(self, type, node_id, this);
         return false;
       });

       self.find("ul.subnav li input.metadata-autocomplete").each(function() {
         GNITE.Tree.Node.autoComplete(self, type, node_id, this);
       });

     } else if(self.hasClass("rank")) {
       self.dblclick(function() {
         self.unbind('dblclick');
         GNITE.Tree.MasterTree.editMetadata(self, type, "PUT", '/vocabularies/rank.json');
       });

     } else if(self.hasClass("metadata-add")) {
       self.click(function() { GNITE.Tree.MasterTree.editMetadata(self, type, "POST"); });
     }
   });
};

GNITE.Tree.Node.autoComplete = function(elem, type, node_id, obj) {
  $(obj).blur(function() {
    $(obj).parent().parent().hide();
    GNITE.Tree.Node.updateMetadata(elem, type, node_id, obj);
  }).keyup(function(event) {
      var key = event.keyCode || event.which;
      if(key === 27) { this.blur(); return; }
      else if(key === 13) { this.blur(); return; }
  }).keypress(function(event) {
      var key = event.keyCode || event.which;
      if(key === 13) { return false; }
  });
};

GNITE.Tree.Node.updateMetadata = function(elem, type, node_id, obj) {
  var data = {};

  if(elem.hasClass("synonym")) {
    data = { status : $(obj).text() }
  }
  if(elem.hasClass("vernacular")) {
    data = { language_id : $(obj).attr("data-term-id") }
  }

  GNITE.Tree.MasterTree.reconciliation({ 
    type           : type, 
    action         : 'PUT', 
    id             : elem.attr("id").split("-")[1],
    destination_id : node_id,
    data           : data
  });
};

GNITE.Tree.MasterTree.editMetadata = function(elem, type, action, autocomplete_url) {

  "use strict";

  var container = elem.parents(".node-metadata"),
      elem_id   = (elem.attr("id")) ? elem.attr("id").split("-")[1] : null,
      selected  = $('#master-tree').jstree('get_selected'),
      node_id   = $(selected[0]).attr("id"),
      width     = (elem.width() < 150) ? 150 : elem.width(),
      position  = "",
      t         = "",
      input     = "";

  elem.find("ul.subnav").hide();

  if(elem.hasClass("metadata-add")) {
    elem.before("<li><a href=\"#\" class=\"selected\"><span>&nbsp;</span></a></li>").prev().addClass("active-edit").find("a.selected").css({"width" : width});
  } else {
    elem.addClass("active-edit").removeClass("jstree-draggable").unbind('mouseenter mouseleave').find("a:first").css({"width" : width});
    t = elem.find("a:first span").text();
  }

  elem.find("a.selected").css({"width" : width});

  input =  $("<input />", { 
    "value"        : t,
    "class"        : "metadata-input",
    "name"         : type,
    "type"         : "text",
    "data-term-id" : "",
    "css"          : {"width" : width},
    "blur"         : $.proxy(function() {
      var i = (elem.hasClass("metadata-add")) ? elem.prev().children(".metadata-input") : elem.children(".metadata-input"),
          v = i.val();

      if(v === "") { v = t; }
      if(elem.hasClass("metadata-add")) { elem.prev().text(v); } else { elem.text(v); }
      i.remove();
      elem.removeClass("active-edit");
      if(t !== v) {
        container.spinner();
        if(type === "ranks") {
          $.ajax({
            type        : 'PUT',
            async       : true,
            url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/nodes/' + node_id + '.json',
            data        : JSON.stringify({ 'node' : {  }, 'json_message' : { 'do' : v }, 'action_type' : 'ActionChangeRank' }),
            contentType : 'application/json',
            dataType    : 'json',
            beforeSend  : function(xhr) {
              xhr.setRequestHeader("X-Session-ID", jug.sessionID);
            },
          });
        } else {
          GNITE.Tree.MasterTree.reconciliation({ 
            type           : type, 
            action         : action, 
            id             : elem_id, 
            destination_id : node_id,
            data           : {
              name_string : v
            }
          });
        }
        container.unspinner();
      }
      t = v;
      $('#master-tree').jstree("deselect_all").jstree("select_node", $('#' + node_id));
    }, this),
    "keyup" : function(event) {
      var key = event.keyCode || event.which;

      if(key === 27) { this.value = t; this.blur(); return; }
      else if(key === 13) { this.blur(); return; }
    },
    "keypress" : function(event) {
      var key = event.keyCode || event.which;
      if(key === 13) { return false; }
    }
  });

  if(elem.hasClass("metadata-add")) {
    elem.prev().append(input).children(".metadata-input").focus();
    if(autocomplete_url) { $(".metadata-input").inlineComplete({ terms: autocomplete_url }); }
    elem.hide();
  } else {
    elem.append(input).children(".metadata-input").focus();
    if(autocomplete_url) { $(".metadata-input").inlineComplete({ terms: autocomplete_url }); }
    elem.parent().find(".metadata-add").hide();
  }

};

GNITE.Tree.MasterTree.reconciliation = function(params) {

  "use strict";

  var self = $('#master-tree'),
      url  = "/master_trees/" + GNITE.Tree.MasterTree.id + "/nodes/" + params.destination_id + "/" + params.type;

  switch(params.action) {
    case 'POST':
      url += ".json";
    break;
    case 'PUT':
      url += "/" + params.id + ".json";
    break;
    case 'DELETE':
      url += "/" + params.id + ".json";
    break;
  }

  $.ajax({
    type        : params.action,
    async       : false,
    url         : url,
    data        : JSON.stringify(params.data),
    dataType    : 'json',
    contentType : 'application/json',
    beforeSend  : function(xhr) {
      xhr.setRequestHeader("X-Session-ID", jug.sessionID);
    },
    success : function() {
      GNITE.Tree.MasterTree.refreshMetadata(params.destination_id);
    }
  });

};

GNITE.Tree.MasterTree.refreshMetadata = function(node_id) {

  "use strict";

  var self     = $('#master-tree'),
      selected = self.jstree("get_selected");

  if(selected[0].id === node_id || self.find("a.jstree-clicked").parent().attr("id") === node_id.toString()) {
    self.jstree("deselect_all").jstree("select_node", $('#' + node_id));
  }

};
