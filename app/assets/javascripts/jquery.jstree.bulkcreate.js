/*
 * jsTree bulk create plugin
 */
(function ($) {
    $.jstree.plugin("bulkcreate", {
        __init : function () {
            this._bulk_initialize();
        },
        defaults : {
          element : "#bulkcreate-form"
        },
        _fn : {
            _bulk_initialize : function() {
              var self = this;
              var s = self.get_settings().bulkcreate;
              $(s.element).dialog({
                closeText: '',
                autoOpen: false,
                height: 'auto',
                width: 450,
                modal: true,
                resizable: false,
                buttons: [
                  {
                    'class' : "green-submit",
                    text : "Add children",
                    click : function() {
                      var bValid = true;
                      $(s.addition_form).find(".input").removeClass("ui-state-error");
                      bValid = bValid && self._bulk_validate($(s.element).find(".text"));
                      if (bValid) {
                        self.bulk_save();
                        $(this).dialog("close");
                      }
                    }
                  },
                  {
                    'class' : "cancel-button",
                    text : "Cancel",
                    click : function() {
                      $(this).dialog("close");
                    }
                  }
                ],
                close: function() {
                  $(s.element).find(".text").removeClass("ui-state-error");
                  return false;
                }
              });
            },
            bulk_form : function (obj, callback) {
                obj = this._get_node(obj, true);
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            bulk_save : function (obj, callback) {
                obj = this._get_node(obj, true);
                this.__callback({ "obj" : obj });
                if(callback) { callback.call(); }
            },
            _bulk_validate : function(o) {
                if (o.val().length == 0) {
                  o.addClass("ui-state-error");
                  return false;
                }
                else {
                  return true;
                }
            },
        }
    });
    // include bookmarks by default
    $.jstree.defaults.plugins.push("bulk_create");
})(jQuery);