/*
 * TODO: Need to be fleshed out
 * jsTree bookmarks plugin
 */
(function ($) {
    $.jstree.plugin("undoredo", {
        __init : function() {
        },
        defaults : {
        },
        _fn : {
          undo : function(obj, callback) {
            if(!obj) { obj = -1; }
            obj = this._get_node(obj, true);
            this.__callback({ "obj" : obj });
            if(callback) { callback.call(); }
          },
          redo : function(obj, callback) {
            if(!obj) { obj = -1; }
            obj = this._get_node(obj, true);
            this.__callback({ "obj" : obj });
            if(callback) { callback.call(); }
          }
        }
    });
    // include undoredo by default
    $.jstree.defaults.plugins.push("undoredo");
})(jQuery);