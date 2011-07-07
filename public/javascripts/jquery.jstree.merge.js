/*
 * jsTree merge plugin
 */
(function ($) {
    $.jstree.plugin("merge", {
        __init : function() {
            this._merge_initialize();
        },
        defaults : {
          merge_form   : '#merge-form',
        },
        _fn : {
            merge_form : function (obj, callback) {
                obj = this._get_node(obj, true);
                if(!obj || !obj.length) { return false; }
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            merge_submit : function (obj, callback) {
                obj = this._get_node(obj, true);
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            _merge_initialize : function() {
                var self = this;
                var s = self.get_settings().merge;
                $(s.merge_form).dialog({
                        closeText: '',
                        autoOpen: false,
                        height: 250,
                        width: 450,
                        modal: true,
                        resizable: false,
                        buttons: [
                          {
                            'class' : "green-submit",
                            text : "Merge",
                            click : function() {
                              self.merge_submit();
                            }
                          },
                          {
                            'class' : "cancel-button",
                            text : "Cancel",
                            click : function() {
                              $(this).dialog("close");
                            }
                          }
                        ]
                  })
                  .keypress(function(event) {
                    if (event.which == 13) {
                      self.merge_save();
                      $(this).dialog("close");
                      return false;
                    }
                  });
            }
        }
    });
    // include bookmarks by default
    $.jstree.defaults.plugins.push("merge");
})(jQuery);