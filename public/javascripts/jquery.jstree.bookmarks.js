/*
 * jsTree bookmarks plugin
 */
(function ($) {
	$.jstree.plugin("bookmarks", {
		__init : function () {
		},
		defaults : {
		},
		_fn : {
			bookmark : function (obj, callback) {
				obj = this._get_node(obj, true);
				if(!obj || !obj.length) { return false; }
				this.__callback({ "obj" : obj });
				if(callback) { callback.call(); }
			}
		}
	});
	// include bookmarks by default
	$.jstree.defaults.plugins.push("bookmarks");
})(jQuery);