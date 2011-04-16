/*
 * jsTree bulk create plugin
 */
(function ($) {
    $.jstree.plugin("bulkcreate", {
        __init : function () {
            this._bulk_initialize();
        },
        defaults : {
          form_element : "#bulkcreate-form"
        },
        _fn : {
            _bulk_initialize : function() {
              var self = this;
              var s = self.get_settings().bulkcreate;
              $(s.form_element).dialog({
                closeText: '',
                autoOpen: false,
                height: 'auto',
                width: 450,
                modal: true,
                buttons: [
                  {
                    className : "green-submit",
                    text : "Add children",
                    click : function() {
                      self.bulksave();
                      $(this).dialog("close");
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
                  allFields.val("").removeClass("ui-state-error");
                  return false;
                }
              });
            },
            bulkcreate : function (obj, callback) {
                obj = this._get_node(obj, true);
                if(!obj || !obj.length) { return false; }
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            bulksave : function (obj, callback) {
                obj = this._get_node(obj, true);
                if(!obj || !obj.length) { return false; }
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            }
        }
    });
    // include bookmarks by default
    $.jstree.defaults.plugins.push("bulkcreate");
})(jQuery);