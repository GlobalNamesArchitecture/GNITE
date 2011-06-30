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
    var merge_decisions = [], i = 0, id = "", decision_id;

    switch($(this).attr("class")) {
      case 'accepted':
        $(this).parents("table").find("input.accepted").each(function() {
          $(this).attr("disabled", "disabled");
          id = $(this).attr("name").split("-")[1];
          decision_id = $(this).val();
          merge_decisions.push({ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id });
          $(this).attr("checked", true);
        });
      break;

      case 'postponed':
        $(this).parents("table").find("input.postponed").each(function() {
          $(this).attr("disabled", "disabled");
          id = $(this).attr("name").split("-")[1];
          decision_id = $(this).val();
          merge_decisions.push({ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id });
          $(this).attr("checked", true);
        });
      break;

      case 'rejected':
        $(this).parents("table").find("input.rejected").each(function() {
          $(this).attr("disabled", "disabled");
          id = $(this).attr("name").split("-")[1];
          decision_id = $(this).val();
          merge_decisions.push({ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id });
          $(this).attr("checked", true);
        });
      break;
    }

    $.ajax({
      type        : 'PUT',
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/merge_events/' + GNITE.Tree.MasterTree.merge_event,
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
      url         : '/master_trees/' + GNITE.Tree.MasterTree.id + '/merge_events/' + GNITE.Tree.MasterTree.merge_event,
      data        : JSON.stringify({'data' : [{ 'merge_result_secondary_id' : id, 'merge_decision_id' : decision_id }]}),
      contentType : 'application/json',
      dataType    : 'json',
      success     : function(data) {
        if(data.status == "OK") { $(self).removeAttr("disabled"); }
      }
    });

  });

});