/*
 * jsTree bookmarks plugin
 */
(function ($) {
    $.jstree.plugin("bookmarks", {
        __init : function() {
            this._bookmarks_initialize();
        },
        defaults : {
          addition_form : '#bookmarks-addition-form',
          viewer_form   : '#bookmarks-viewer'
        },
        _fn : {
            bookmarks_view : function (obj, callback) {
                if(!obj) { obj = -1; }
                obj = this._get_node(obj, true);
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            bookmarks_form : function (obj, callback) {
                obj = this._get_node(obj, true);
                if(!obj || !obj.length) { return false; }
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            bookmarks_save : function (obj, callback) {
                obj = this._get_node(obj, true);
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            _bookmarks_validate : function(o, min, max) {
                if (o.val().length > max || o.val().length < min) {
                  o.addClass("ui-state-error");
                  return false;
                }
                else {
                  return true;
                }
            },
            _bookmarks_initialize : function() {
                var self = this;
                var s = self.get_settings().bookmarks;
                $(s.addition_form).dialog({
                        closeText: '',
                        autoOpen: false,
                        height: 220,
                        width: 450,
                        modal: true,
                        buttons: [
                          {
                            className : "green-submit",
                            text : "Add bookmark",
                            click : function() {
                                var bValid = true;
                                $(s.addition_form).find(".input").removeClass("ui-state-error");
                                bValid = bValid && self._bookmarks_validate($(s.addition_form).find(".input"), 1, 50);
                                if (bValid) {
                                  self.bookmarks_save();
                                  $(this).dialog("close");
                                }
                            }
                          },
                          {
                            className : "cancel-button",
                            text : "Cancel",
                            click : function() {
                              $(this).dialog("close");
                            }
                          }
                        ],
                        close: function() {
                          $(s.addition_form).find(".input").val("").removeClass("ui-state-error");
                          return false;
                        }
                  })
                  .keypress(function(event) {
                    if (event.which == 13) {
                        var bValid = true;
                        $(s.addition_form).find(".input").removeClass("ui-state-error");
                        bValid = bValid && self._bookmarks_validate($(s.addition_form).find(".input"), 1, 50);
                        if (bValid) {
                          self.bookmarks_save();
                          $(this).dialog("close");
                        }
                        return false;
                    }
                  });
                $(s.viewer_form).dialog({
                        closeText: '',
                        autoOpen: false,
                        height: 250,
                        width: 450,
                        modal: true,
                        buttons: [
                          {
                            className : "green-submit",
                            text : "Close",
                            click : function() {
                              $(this).dialog("close");
                            }
                          }
                        ],
                        close: function() {
                          return false;
                        }
                  });
            }
        }
    });
    // include bookmarks by default
    $.jstree.defaults.plugins.push("bookmarks");
})(jQuery);