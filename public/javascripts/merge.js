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
});