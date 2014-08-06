/*global $, document, Juggernaut, setTimeout, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = GNITE || {
  MergeEvent : {
    Tree : { }
  },
  Chat     : {},
  jug      : new Juggernaut(),
  channel  : "",
  token    : "",
  user_id  : "",
  response : {}
};

/****************** START jQUERY ****************************/
$(function() {

  "use strict";

  GNITE.token = $("meta[name='csrf-token']").attr("content");
  GNITE.channel = "tree_" + GNITE.MergeEvent.master_tree_id;

  /****************** JUGGERNAUT ***************************/

  if(GNITE.MergeEvent.merge_status === "computing") {
     $('#chat-messages-wrapper').hide();
     GNITE.response = (GNITE.MergeEvent.merge_last_log) ? GNITE.MergeEvent.merge_last_log : 'Starting merge...';
     $('#content').spinner().find(".spinner").append('<p class="status">' + GNITE.response + '</p>');
  }

  if($('#chat-messages-wrapper').length > 0) {
    GNITE.jug.meta = { master_tree_id: GNITE.MergeEvent.master_tree_id, user_id: GNITE.user_id };
  }
  GNITE.jug.on("connect", function() { "use strict"; $('#merge-results-wrapper').addClass("juggernaut-connected"); });
  GNITE.jug.on("disconnect", function() { "use strict"; });

  GNITE.jug.subscribe(GNITE.channel, function(data) {
    var response = $.parseJSON(data);

    switch(response.subject) {
      case 'member-login':
        if(GNITE.user_id !== response.user.id.toString()) { GNITE.Chat.flashChatWindow(); }
        GNITE.Chat.appendMessage("new-user", response);
      break;

      case 'chat':
        GNITE.Chat.flashChatWindow();
        GNITE.Chat.appendMessage("chat", response);
      break;

      case 'MergeEvent':
        if(response.message === "Merging is complete") {
          $(".spinner").find(".status").html(response.message);
          $("#content").addClass("merge-complete").delay(2000).queue(function() {
            $(".spinner").find(".status").html("Reloading...");
            var url   = "/master_trees/" + GNITE.MergeEvent.master_tree_id + "/merge_events/" + GNITE.MergeEvent.merge_event,
                input = '<input type="hidden" name="" value="" />';
            jQuery('<form action="'+ url +'" method="GET">'+input+'</form>').appendTo('body').submit().remove();
          });
        } else {
          $(".spinner").find(".status").html(response.message);
        }
      break;

      case 'roster':
        if(response.status == "destroy" && GNITE.user_id !== response.user.id.toString()) {
          GNITE.Chat.flashChatWindow();
          GNITE.Chat.appendMessage("departed", response);
        }
        $('#chat-messages-user-count').html("(" + response.count + ")").show();
        GNITE.Chat.editChatUserStatus(response);
      break;
    }
  });

  $('#merge-results-wrapper').waypoint().find('#treewrap-main').waypoint(function(event, direction) {
    if($(this).hasClass("opened") && direction === "up") { $(this).parent().addClass('docked').removeClass("sticky"); }
    if($(this).hasClass("opened") && direction === "down") { $(this).parent().removeClass("docked").addClass("sticky"); }
    event.stopPropagation();
  });

  /**************************************************************
           TREE CONFIGURATION
  **************************************************************/
  GNITE.MergeEvent.Tree.configuration = {
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
    'hotkeys' : {
      'return'       : function() { if(this.data.ui.hovered) { this.data.ui.hovered.children("a:eq(0)").click(); } },
      'ctrl+r'       : function() { this.refresh( this.data.ui.hovered || this._get_node(null) ); },
      'ctrl+shift+r' : function() { this.refresh(); },
      'ctrl+c'       : function() { this.close_all(); }
    },
    'plugins' : ['themes', 'html_data', 'hotkeys', 'ui']
  };

  if ($.fn.jstree && GNITE.MergeEvent.merge_status && GNITE.MergeEvent.merge_status !== "computing") {
    $('#preview-tree').jstree($.extend(true, {}, GNITE.MergeEvent.Tree.configuration, {
      'html_data': {
        'ajax' : {
          'url'   : '/merge_trees/' + GNITE.MergeEvent.merge_tree_id + '/nodes',
          'error' : function() {
            $('#preview-tree').find("span.jstree-loading").remove();
          }
        }
      }
    }));

    $('#preview-tree').bind('load_node.jstree', function(event, data) {
      event = null;
      var node = data.rslt;

      if(node.obj !== -1) { node.obj.find("span.jstree-loading").remove(); }
    });

    $('#preview-tree').bind('select_node.jstree', function(event, data) {
      event = null;
      var self     = $(this),
          metadata = self.parent().parent().next(),
          wrapper  = self.parent().parent(),
          url      = '/merge_trees/' + GNITE.MergeEvent.merge_tree_id + '/nodes/' + data.rslt.obj.attr("id");

      GNITE.MergeEvent.Tree.getMetadata(url, metadata, wrapper);
    });
  }

  $('.header-decision a').click(function () {

    var merge_decisions = [],
        decision        = $(this).attr("class"),
        i               = 0,
        id              = "",
        decision_id     = 0,
        num_decisions   = $("td.merge-decision").size(),
        decision_item   = "",
        postponed       = false;

    $(this).parents("table").find("input." + decision).each(function() {
      $(this).attr("disabled", "disabled");
      id = $(this).attr("name").split("-")[1];
      decision_id = $(this).val();
      merge_decisions.push({ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id });
      $(this).attr("checked", true);
    });

    if(decision === "postponed") { 
      postponed = true;
    } else {
      for(var i = 0; i < num_decisions; i += 1) {
        decision_item = $("td.merge-decision:eq(" + i + ") ");
        $(".merge-input", decision_item).each(function() {
          if($(this).prop("checked") && $(this).val() === "3") { postponed = true; return false; }
        });
        if(decision_item.find("input:checked").size() === 0) { postponed = true; }
        if(postponed) { break; }
      }
    }

    if(postponed) {
      $("input.submit").addClass("disabled").attr("disabled", true);
    } else {
      $("input.submit").removeClass("disabled").attr("disabled", false);
    }

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.MergeEvent.master_tree_id + '/merge_events/' + GNITE.MergeEvent.merge_event,
      data        : JSON.stringify({ 'data' : merge_decisions }),
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
      },
      success     : function(data) {
        if(data.status === "OK") {
          for(i = 0; i < merge_decisions.length; i += 1) {
            $('input[name="merge-' + merge_decisions[i].merge_result_secondary_id + '"]').removeAttr("disabled");
          }
          GNITE.MergeEvent.showMergeWarning();
        }
      }
    });

    return false;
  });

  $('input.merge-input').click(function() {

    var self          = this,
        decision_id   = $(this).val(),
        id            = $(this).attr("name").split("-")[1],
        num_decisions = $("td.merge-decision").size(),
        decision_item = "",
        postponed     = false;

    $(self).attr("disabled", "disabled");

    if(decision_id === "3") {
      postponed = true;
    } else {
      for(var i = 0; i < num_decisions; i += 1) {
        decision_item = $("td.merge-decision:eq(" + i + ")");
        $(".merge-input", decision_item).each(function() {
          if($(this).prop("checked") && $(this).val() === "3") { postponed = true; return false; }
        });
        if(decision_item.find("input:checked").size() === 0) { postponed = true; }
        if(postponed) { break; }
      }
    }

    if(postponed) {
      $("input.submit").addClass("disabled").attr("disabled", true);
    } else {
      $("input.submit").removeClass("disabled").attr("disabled", false);
    }

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.MergeEvent.master_tree_id + '/merge_events/' + GNITE.MergeEvent.merge_event,
      data        : JSON.stringify({'data' : [{ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id }]}),
      contentType : 'application/json',
      dataType    : 'json',
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
      },
      success     : function(data) {
        if(data.status === "OK") { 
          $(self).removeAttr("disabled");
          GNITE.MergeEvent.showMergeWarning();
        }
      }
    });

  });

  $('#merge-results-wrapper .ui-dialog-titlebar-close').click(function() {
    $('#treewrap-main').removeClass("opened").parent().removeClass("sticky docked");
    $('#merge-results-table').removeClass("squeezed");
    return false;
  });

  /**************************** PREVIEW TREE *********************************/
  $('input.preview').click(function() {

    if($('#treewrap-main').hasClass('opened')) {
      $('.node-metadata').hide();
      $('#preview-tree').jstree("deselect_all").parent().parent().css('bottom','20px');
      GNITE.MergeEvent.generatePreview();
    } else {
      $('#merge-results-table').addClass("squeezed");
      $.waypoints('refresh');
      $('#treewrap-main').addClass('opened').parent().addClass("sticky");
      if($('#merge-results-wrapper').offset().top - $('#treewrap-main').offset().top > 0) {
        $('#treewrap-main').parent().removeClass("sticky").addClass("docked");
      }
      GNITE.MergeEvent.generatePreview();
    }

    return false;
  });

  /**************************** SUBMIT ************************************/
  $('input.submit').click(function() {

    var message = 'You have not yet made any decisions';

    //TODO: find if there is a single row (i.e. radio inputs with name="name-x") that is unselected
    if($('.merge-input:checked').length === 0) {
      $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Warning">' + message + '</div>');
      $('#dialog-message').dialog({
        height    : 200,
        width     : 500,
        modal     : true,
        closeText : "",
        buttons   : [
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
     $('.ui-dialog-titlebar-close').click(function() {
       $('#dialog-message').dialog("destroy").remove();
     });
     return false;
   }

  });

  /**************************************************************
           SEARCH WITHIN PREVIEW
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
          url        : '/tree_searches/' + self.parents('.tree-background').find('.tree-container').attr('data-database-id') + '/' + term,
          type       : 'GET',
          data       : { },
          beforeSend : function(xhr) {
            xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
          },
          success    : function(data) {
            results.html(data);
            results.find("a").click(function() {
               results.hide();
               tree.jstree("deselect_all");
               var ancestry_arr = $(this).attr("data-treepath-ids").split(",");
               GNITE.MergeEvent.openAncestry(tree, ancestry_arr);
               return false;
            });
          },
          complete   : function() {
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

  GNITE.MergeEvent.generatePreview = function() {

    "use strict";

    $('#merge-warning').hide();
    $('.tree-background').spinner();
    $('#preview-tree').removeClass("merge-complete").jstree("close_all").jstree("lock");
    $.ajax({
      type       : 'GET',
      url        : '/merge_trees/' + GNITE.MergeEvent.merge_tree_id + '/populate',
      data       : {},
      beforeSend : function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
      },
      success    : function(populate_response) {
        setTimeout(function checkStatus() {
          if(populate_response.status !== "OK") {
            setTimeout(checkStatus, 100);
          } else {
            $('#preview-tree').addClass("merge-complete").jstree("unlock").jstree("refresh");
            $('.tree-background').unspinner();
          }
        }, 100);
      }
    }); 
  };

  GNITE.MergeEvent.openAncestry = function(tree, obj) {

    "use strict";

    var _this         = this, 
        done          = true,
        end           = "",
        current       = [],
        remaining     = [],
        tree_wrapper  = tree.parents('#add-node-wrap');

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

  GNITE.MergeEvent.showMergeWarning = function() {

    "use strict";

    if($('#treewrap-main').is(':visible')) {
      $('#preview-tree').jstree("lock");
      $('#merge-warning').show();
      $('.node-metadata').hide();

      $('#merge-warning a').click(function() {
        GNITE.MergeEvent.generatePreview();
        return false;
      });
    }
  };

  GNITE.MergeEvent.Tree.getMetadata = function(url, container, wrapper) {

    "use strict";

    container.spinner();

    $.ajax({
      type        : 'GET',
      url         : url,
      contentType : 'text/html',
      dataType    : 'html',
      beforeSend : function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
      },
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

});
/****************** END jQUERY ****************************/