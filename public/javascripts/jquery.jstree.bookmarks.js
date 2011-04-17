/*
 * jsTree bookmarks plugin
 */
(function ($) {
    $.jstree.plugin("bookmarks", {
        __init : function () {
            this._bookmarks_initialize();
        },
        defaults : {
          element : "#bookmarks"
        },
        _fn : {
            bookmark : function (obj, callback) {
                obj = this._get_node(obj, true);
                if(!obj || !obj.length) { return false; }
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            _bookmarks_initialize : function() {
                var self = this;
                var s = self.get_settings().bookmarks;
                $(s.element).dialog({
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
                          allFields.val("").removeClass("ui-state-error");
                          return false;
                        }
                  });
            }
        }
    });
    // include bookmarks by default
    $.jstree.defaults.plugins.push("bookmarks");
})(jQuery);