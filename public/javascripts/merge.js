/*global $, document, Juggernaut, setTimeout, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = {
  Tree : {
    MasterTree      : {}
  }
};


$(function() {

  if(GNITE.Tree.MasterTree.merge_status && GNITE.Tree.MasterTree.merge_status === "computing") {

     var  jug               = new Juggernaut(),
          container         = $("#content"),
          message_wrapper   = {};

     container.spinner();
     message_wrapper = container.find(".spinner").append('<p class="status">Starting merge...</p>');

     GNITE.Tree.MasterTree.channel = "tree_"+GNITE.Tree.MasterTree.id;

     jug.on("connect", function() { "use strict"; $('#merge-results-wrapper').addClass("juggernaut-connected"); });
     jug.on("disconnect", function() { "use strict"; });

     jug.subscribe(GNITE.Tree.MasterTree.channel, function(data) {
        var response = $.parseJSON(data);

        switch(response.message) {
          case "Merging is complete":
            jug.unsubscribe("tree_" + GNITE.Tree.MasterTree.channel);
            message_wrapper.find(".status").html(response.message);
            container.addClass("merge-complete").delay(2000).queue(function() {
              $(this).find(".status").html("Reloading...");
              window.location = "/master_trees/" + GNITE.Tree.MasterTree.id + "/merge_events/" + GNITE.Tree.MasterTree.merge_event;
            });
            break;

            default:
              message_wrapper.find(".status").html(response.message);
          }
     });

  }

  $('.header-decision a').click(function () {
    //TODO: make array to submit to PUT controller

    switch($(this).attr("class")) {
      case 'accepted':
        $(this).parents("table").find("input.accepted").attr("checked", true);
      break;

      case 'postponed':
        $(this).parents("table").find("input.postponed").attr("checked", true);
      break;

      case 'rejected':
        $(this).parents("table").find("input.rejected").attr("checked", true);
      break;
    }

/*
    $.ajax({
      type        : 'PUT',
      url         : url,
      data        : JSON.stringify({ 'id' : id, 'value' : value }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function() {
      },
      error       : function() {
      }
    });
*/
    return false;
  });

  $('input.merge-input').click(function() {
    //TODO: pass variables to PUT controller

    var value = $(this).val(),
        id    = $(this).attr("name").split("-")[1];

    $(this).attr("disabled", "disabled");
/*
    $.ajax({
      type        : 'PUT',
      url         : url,
      data        : JSON.stringify({ 'id' : id, 'value' : value }),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function() {
      },
      error       : function() {
      }
    });
*/
    $(this).removeAttr("disabled");

  });

});