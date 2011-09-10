/*global $, document, Juggernaut, setTimeout, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/
var GNITE = GNITE || {
  jug : new Juggernaut()
};

/********************************* jQuery START *********************************/
$(function() {

  "use strict";

  GNITE.channel = "admin_roster";

   /**************************************************************
           JUGGERNAUT LISTENER
  **************************************************************/
  GNITE.jug.subscribe(GNITE.channel, function(data) {
    var response = $.parseJSON(data);

    $('#admin-user-count span').text(response.count);

    if(response.status === "create") {
      $("td.chat-user-" + response.user.id).removeClass("offline").addClass("online").html("<a href=\"/master_tree/" + response.master_tree_id + "\">online</a>");
    } else { 
      $("td.chat-user-" + response.user.id).removeClass("online").addClass("offline").html("offline");
    }

  });

});