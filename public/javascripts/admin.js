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
      $("td.chat-user-" + response.user.id).removeClass("offline").addClass("online").text("online");
    } else { 
      $("td.chat-user-" + response.user.id).removeClass("online").addClass("offline").text("offline");
    }

  });

});