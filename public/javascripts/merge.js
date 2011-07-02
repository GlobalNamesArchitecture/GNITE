/*global $, document, Juggernaut, setTimeout, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = {
  MergeEvent : {
    Tree : { }
  }
};

/****************** START jQUERY ****************************/
$(function() {

  "use strict";

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
          metadata = self.parent().next(),
          wrapper  = self.parent(),
          url      = '/merge_trees/' + GNITE.MergeEvent.merge_tree_id + '/nodes/' + data.rslt.obj.attr("id");
      GNITE.MergeEvent.Tree.getMetadata(url, metadata, wrapper);
    });
  }

  if(GNITE.MergeEvent.merge_status && GNITE.MergeEvent.merge_status === "computing") {

     var jug               = new Juggernaut(),
         container         = $("#content"),
         message_wrapper   = {},
         response          = "";

     container.spinner();
     message_wrapper = container.find(".spinner").append('<p class="status">Starting merge...</p>');

     GNITE.MergeEvent.channel = "tree_" + GNITE.MergeEvent.master_tree_id;

     jug.on("connect", function() { "use strict"; $('#merge-results-wrapper').addClass("juggernaut-connected"); });
     jug.on("disconnect", function() { "use strict"; });

     jug.subscribe(GNITE.MergeEvent.channel, function(data) {
        response = $.parseJSON(data);

        switch(response.message) {
          case "Merging is complete":
            message_wrapper.find(".status").html(response.message);
            jug.unsubscribe("tree_" + GNITE.MergeEvent.channel);
            container.addClass("merge-complete").delay(2000).queue(function() {
              $(this).find(".status").html("Reloading...");
              window.location = "/master_trees/" + GNITE.MergeEvent.master_tree_id + "/merge_events/" + GNITE.MergeEvent.merge_event;
            });
            break;

          default:
            message_wrapper.find(".status").html(response.message);
        }
     });
  }

  $('.header-decision a').click(function () {

    var merge_decisions = [],
        decision        = $(this).attr("class"),
        i               = 0,
        id              = "",
        decision_id     = 0;

    $(this).parents("table").find("input." + decision).each(function() {
      $(this).attr("disabled", "disabled");
      id = $(this).attr("name").split("-")[1];
      decision_id = $(this).val();
      merge_decisions.push({ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id });
      $(this).attr("checked", true);
    });

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.MergeEvent.master_tree_id + '/merge_events/' + GNITE.MergeEvent.merge_event,
      data        : JSON.stringify({ 'data' : merge_decisions }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        if(data.status == "OK") {
          for(i = 0; i < merge_decisions.length; i += 1) {
            $('input[name="merge-' + merge_decisions[i].merge_result_secondary_id + '"]').removeAttr("disabled");
          }
        }
      }
    });

    return false;
  });

  $('input.merge-input').click(function() {

    var self        = this,
        decision_id = $(this).val(),
        id          = $(this).attr("name").split("-")[1];

    $(self).attr("disabled", "disabled");

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.MergeEvent.master_tree_id + '/merge_events/' + GNITE.MergeEvent.merge_event,
      data        : JSON.stringify({'data' : [{ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id }]}),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        if(data.status == "OK") { $(self).removeAttr("disabled"); }
      }
    });

  });

  $('#merge-results-preview .ui-dialog-titlebar-close').click(function() {
    $('#merge-results-preview').hide();
    $('#merge-results-table').animate({
      width:'100%'
    }, 1000);
    return false;
  })

  /**************************** PREVIEW TREE *********************************/
  $('input.preview').click(function() {

    if($('#merge-results-preview').is(":visible")) {
      $('#preview-tree').jstree("deselect_all");
      $('.node-metadata').hide();
      $('.tree-container').css('bottom', '5px');
      GNITE.MergeEvent.generatePreview();
    } else {
      $('#merge-results-table').animate({
        width:'64%'
      }, 1000, function() { 
        $('#merge-results-preview').show().animate({ width:'28%'}, 1000);
        GNITE.MergeEvent.generatePreview();
      });
    }

    return false;
  });

  /**************************** SUBMIT ************************************/
  $('input.submit').click(function() {

    var message = 'You have not yet made any decisions';

    if($('.merge-input:checked').length === 0) {
      $('body').append('<div id="dialog-message" class="ui-state-highlight" title="Warning">' + message + '</div>');
      $('#dialog-message').dialog({
        height    : 200,
        width     : 500,
        modal     : true,
        closeText : "",
        buttons   : [
         {
           className : "green-submit",
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

  GNITE.MergeEvent.generatePreview = function() {
    $('#merge-results-preview .tree-container').spinner();
    $('#preview-tree').removeClass("merge-complete").jstree("close_all").jstree("lock");
    $.get('/merge_trees/' + GNITE.MergeEvent.merge_tree_id + '/populate', {}, function(populate_response) {
      setTimeout(function checkStatus() {
        if(populate_response.status !== "OK") {
          setTimeout(checkStatus, 100);
        } else {
          $('#preview-tree').addClass("merge-complete").jstree("unlock").jstree("refresh");
          $('#merge-results-preview .tree-container').unspinner();
        }
      }, 100);
    }, 'json'); 
  };

  GNITE.MergeEvent.Tree.getMetadata = function(url, container, wrapper) {

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
          wrapper.css('bottom', '5px');
          return false;
        });
      }
    });

    container.unspinner().show();
    wrapper.css('bottom', container.height());
  };

});
/****************** END jQUERY ****************************/