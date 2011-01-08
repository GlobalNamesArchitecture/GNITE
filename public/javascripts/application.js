/*
 * Options
 */
var GNITE = {
  Tree          : {},
  MasterTree    : {},
  DeletedTree   : {},
  ReferenceTree : {}
};

GNITE.Tree.configuration = {
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

  'crrm': {
    'move': {
      'always_copy' : 'multitree'
    }
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

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search', 'contextmenu']
});

GNITE.ReferenceTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
  'crrm' : {
    'move' : {
      'check_move' : function() { return false; },
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search', 'contextmenu']
});

GNITE.DeletedTree.configuration = $.extend(true, {}, GNITE.Tree.configuration, {
  'crrm' : {
    'move' : {
      'check_move' : function() { return false; },
      'always_copy' : false
    }
  },

  'plugins' : ['themes', 'json_data', 'ui', 'dnd', 'crrm', 'cookies', 'search', 'contextmenu']
});

GNITE.ReferenceTree.add = function(response, options) {
  if ($('a[href="#' + response.domid + '"]').length == 0) {
    var tab   = $('#all-tabs');
    var count = parseInt(tab.text().replace(/[^0-9]+/, ''), 10);

    tab.text('All working trees (' + (count + 1) + ')');

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

  if (options) {
    options.spinnedElement.unspinner()
  }
};



$(function() {

   //hide the working tree tabs unless there's something to show
   if ($('#working-trees li').length == 0) {
     $('#tab-titles li:first-child').hide();
   }

  /*
   * Import a Flat List
   */
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
        'master_tree_id' : $('#tree-container').attr('data-database-id')
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




  /*
   * Nodes
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
   * Reference Trees
   */
  $('.reference-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var tree     = self.parents('.reference-tree');
    var metadata = tree.find('.node-metadata');
    var tree_id  = tree.attr('id').split('_')[2];
    var node_id  = self.parent('li').attr('id');
    var wrapper  = tree.find('.reference_tree_container > div');
    var url      = '/reference_trees/' + tree_id + '/nodes/' + node_id;

    GNITE.Node.getMetadata(url, metadata, wrapper);
  });

  $('.reference_tree_container > div').each(function() {
    var self   = $(this);
    var id     = self.attr('id').split('_')[4];
    var active = self.parents('.reference-tree').hasClass('reference-tree-active');

    if (active) {
        $('#working-trees li a').click(function() {
          if($(this).attr('href').split('_')[2] == id && self.find('ul').length == 0) {
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
   * Deleted Names
   */
  $('.deleted_tree_container > div').each(function() {
    var self   = $(this);
    var id     = self.attr('id').split('_')[4];
    var active = self.parents('.deleted-tree').hasClass('deleted-tree-active');

    if (active) {
      $('#deleted a').click(function() {
        if(self.find('ul').length == 0) {
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
        }
      });
    }
  });

  /*
   * Search GNACLR
   */
  $('#search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var container      = self.parents('.gnaclr-search').first();
        var master_tree_id = $('#tree-container').attr('data-database-id');

        container.spinner();

        $.ajax({
          url     : '/search',
          type    : 'GET',
          data    : { 'search_term' : term, 'master_tree_id' : master_tree_id },
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




  /*
   * Master Tree
   */
  var master_tree_id = $('#tree-container').attr('data-database-id');

  $('#add-node').click(function() {
    $('#master-tree').jstree('create');
  });

  if ($.fn.jstree) {
    $('#master-tree').jstree($.extend(true, {}, GNITE.MasterTree.configuration, {
      'json_data': {
        'ajax' : {
          'url' : '/master_trees/' + master_tree_id + '/nodes.json'
        }
      },
      'search' : {
        'case_insensitive' : true,
        'ajax' : {
          'url' : '/master_trees/' + master_tree_id + '/name_searches.json' 
        },
      }, 
    }));
  }

  /*
   * Deleted Names
   */

  /*
   * Search within master tree
   */
  $('#master-tree-search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        $('#master-tree').jstree("search", term);
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        var self = $(this);
        var term = self.val().trim();

        if(term.length > 0) {
          $('#master-tree').jstree("search", term);
        }
        $(this).blur();
      }
    });

  /*
   * Search within reference trees
   */
  $('.reference-tree-search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var $reference_tree = $('.reference_tree_container .jstree-focused');
        $reference_tree.jstree("search", term);
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        var self = $(this);
        var term = self.val().trim();

        if(term.length > 0) {
            var $reference_tree = $('.reference_tree_container .jstree-focused');
	        $reference_tree.jstree("search", term);
        }
        $(this).blur();
      }
    });

  /*
   * Search within deleted tree
   */
  $('.deleted-tree-search')
    .live('blur', function(){
      var self = $(this);
      var term = self.val().trim();

      if (term.length > 0) {
        var $deleted_tree = $('.deleted_tree_container .jstree-focused');
        $deleted_tree.jstree("search", term);
      }
    })
    .live('keypress', function(event) {
      if (event.which == 13) {
        var self = $(this);
        var term = self.val().trim();

        if(term.length > 0) {
            var $deleted_tree = $('.deleted_tree_container .jstree-focused');
	        $deleted_tree.jstree("search", term);
        }
        $(this).blur();
      }
    });

  $('#master-tree')
  .bind('create.jstree', function(event, data) {
    var node     = data.rslt;
    var name     = node.name;
    var parentID = null;

    if (node.parent != -1) {
      parentID = node.parent.attr('id');
    }

    $.ajax({
      type        : 'POST',
      url         : '/master_trees/' + master_tree_id + '/nodes.json',
      data        : JSON.stringify({ 'node' : { 'name' : { 'name_string' : name }, 'parent_id' : parentID } }),
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

  $('#master-tree').bind('rename.jstree', function(event, data) {
    var node     = data.rslt;
    var id       = node.obj.attr('id');
    var new_name = node.new_name;

    $.ajax({
      type        : 'POST',
      url         : '/master_trees/' + master_tree_id + '/nodes/' + id + '/name_updates.json',
      data        : JSON.stringify({ 'name' : { 'name_string' : new_name } }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        updatedNode.obj.attr('id', data.node.id);
      }
    });
  });

  $('#master-tree').bind('move_node.jstree', function(event, data) {
     var result      = data.rslt;
     var isCopy      = result.cy;

     var parentID    = result.np.attr('id');
     var movedNodeID = result.o.attr('id');

     if (parentID == 'master-tree') {
       parentID = null;
     }

     var url = '/master_trees/' + master_tree_id + '/nodes/' + movedNodeID;

     if (isCopy) {
       url += '/clone';
     }

     url += '.json';

     $.ajax({
       type        : isCopy ? 'POST' : 'PUT',
       url         : url,
       data        : JSON.stringify({ 'node' : { 'parent_id' : parentID } }),
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

  $('#master-tree').bind('remove.jstree', function(event, data) {
    var node = data.rslt;
    var id   = node.obj.attr('id');

    $.ajax({
      type : 'DELETE',
      url  : '/master_trees/' + master_tree_id + '/nodes/' + id + '.json'
    });
  });

  $('#master-tree .jstree-clicked').live('click', function() {
    var self     = $(this);
    var metadata = $('#treewrap-main .node-metadata');
    var wrapper  = $('#add-node-wrap');
    var url      = '/master_trees/' + master_tree_id + '/nodes/' + self.parent('li').attr('id');

    GNITE.Node.getMetadata(url, metadata, wrapper);
  });

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

        $.post('/master_trees/' + master_tree_id, { 'master_tree[title]' : title, '_method' : 'put' }, function(response) {
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
   * Miscellaneous
   */
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
    var opts = { master_tree_id : $('#tree-container').attr('data-database-id'),
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
    var opts = { master_tree_id : $('#tree-container').attr('data-database-id'),
                 title          : self.parent().siblings('table').find('.current-name').text(),
                 url            : self.attr('data-tree-url'),
                 source_id      : self.attr('data-source-id'),
                 spinnedElement : $('#search-results') };

    importTree(opts);

    return false;
  });
});




/*
 * Custom Plugins
 */
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

