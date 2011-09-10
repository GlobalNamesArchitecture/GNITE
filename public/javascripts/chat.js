/*global $, document, window, alert */

/**************************************************************
           GLOBAL VARIABLE(S)
**************************************************************/

var GNITE = GNITE || { Chat : {} };

$(function() {

  if($('#chat-messages-users ul li').length > 0) { $('#chat-messages-wrapper').show(); }

  $('#chat-messages-head').click(function() { GNITE.Chat.toggleChatWindow(); });
  $('#chat-messages-options a').click(function() { GNITE.Chat.toggleChatWindow(); return false; });

  $('#chat-messages-status li a').click(function() { GNITE.Chat.toggleChatPanel(this); return false; });

  $('#chat-messages-input').keypress(function(e) {
    var msg  = $(this).val().replace("\n", ""),
        code = (e.keyCode ? e.keyCode : e.which);
 
    if(code !== 13) { return; }
    if (!$.isBlank(msg)) {
      GNITE.Chat.pushMessage("chat", msg, false);
      $(this).val("");
    }
    return false;
  });

  GNITE.Chat.toggleChatWindow = function() {

    "use strict";

    if($('#chat-messages-wrapper > div:not(:first)').is(':visible')) {
      $('#chat-messages-wrapper > div:not(:first)').hide();
      $('#chat-messages-maximize').show();
      $('#chat-messages-minimize').hide();
    } else {
      $('#chat-messages-wrapper > div:not(:first)').show();
      $('#chat-messages-maximize').hide();
      $('#chat-messages-minimize').show();
    }

    if($('#chat-messages-scroller').is(':visible')) { $('#chat-messages-users').hide(); }

  };

  GNITE.Chat.toggleChatPanel = function(obj) {

    "use strict";

    var self = $(obj).parent();

    if(self.hasClass("show-chat")) {
      $('#chat-messages-scroller').show();
      $('#chat-messages-users').hide();
    } else {
      $('#chat-messages-scroller').hide();
      $('#chat-messages-users').show();
    }

    self.siblings().removeClass("active");
    self.addClass("active");
  };

  GNITE.Chat.flashChatWindow = function() {

    "use strict";

    $('#chat-messages-wrapper').show();
    $('#chat-messages-head').effect("highlight", { color : "green" }, 2000);
    $('#chat-messages-maximize').hide();
    $('#chat-messages-minimize').show();
    $('#chat-messages-wrapper div').show();

    if($('#chat-messages-scroller').is(':visible')) { $('#chat-messages-users').hide(); }
    if($('#chat-messages-users').is(':visible')) { $('#chat-messages-scroller').hide(); }
  };

  GNITE.Chat.appendMessage = function(type, response, environment) {

    "use strict";

    var message = response.message;

    switch(type) {
      case 'new-user':
        message = "<strong>arrived</strong> [" + response.time + "]";
      break;
      case 'departed':
        message = "<strong>departed</strong> [" + response.time + "]";
      break;
      case 'log':
        message = "<strong>edited</strong> [" + response.time + "]</span><span class=\"message\">" + response.message;
      break;
    }

    $('#chat-messages-list').append("<li class=\"" + type + "\"><span class=\"user\">" + response.user.email + "</span>:<span class=\"message\">" + message + "</span></li>").parent().scrollTo('li:last',500);
    $('#chat-messages-users').height($('#chat-messages-scroller').height());

    if(environment === "editor") {
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
    }
  };

  GNITE.Chat.editChatUserStatus = function(response) {

    "use strict";

    if(GNITE.user_id !== response.user.id.toString()) {
      if(response.status == "create") {
        if($('.chat-user-' + response.user.id).length === 0) {
          $('#chat-messages-users ul').append('<li class="chat-user-' + response.user.id + '">' + response.user.email + '</li>');
        }
        $('.chat-user-' + response.user.id).removeClass("offline").addClass("online");
      } else {
        $('.chat-user-' + response.user.id).removeClass("online").addClass("offline");
      }
    }
  };

  GNITE.Chat.pushMessage = function(subject, message, ignore) {

    "use strict";

    $.ajax({
      type        : 'PUT',
      async       : true,
      url         : '/push_messages/',
      contentType : 'application/json',
      dataType    : 'json',
      data        : JSON.stringify({ 'channel' : GNITE.channel, 'subject' : subject, 'message' : message }),
      beforeSend  : function(xhr) {
        xhr.setRequestHeader("X-CSRF-Token", GNITE.token);
        if(ignore) { xhr.setRequestHeader("X-Session-ID", GNITE.jug.sessionID); }
      }
    });
};

});