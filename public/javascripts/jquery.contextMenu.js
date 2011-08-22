/*
 * ContextMenu - jQuery plugin for right-click context menus
 *
 * Author: Chris Domigan
 * Contributors: Dan G. Switzer, II
 * Parts of this plugin are inspired by Joern Zaefferer's Tooltip plugin
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Version: r2
 * Date: 16 July 2007
 *
 * For documentation visit http://www.trendskitchens.co.nz/jquery/contextmenu/
 *
 */

(function($) {

  var menu, trigger, content, hash, currentTarget;
  var defaults = {
    eventPosX: 'pageX',
    eventPosY: 'pageY',
    onContextMenu: null,
    onShowMenu: null
 	};

  $.fn.contextMenu = function(id, options) {
    if (!menu) {                                      // Create singleton menu
      menu = $('<div></div>')
               .hide()
               .attr("id", "ddsmoothmenu-context")
               .css({position:'absolute', zIndex:'1000'})
               .addClass('ddsmoothmenu-v')
               .appendTo('body')
               .bind('click', function(e) {
                 e.stopPropagation();
               });
    }

    hash = hash || [];
    hash.push({
      id : id,
      bindings: options.bindings || {},
      onContextMenu: options.onContextMenu || defaults.onContextMenu,
      onShowMenu: options.onShowMenu || defaults.onShowMenu,
      eventPosX: options.eventPosX || defaults.eventPosX,
      eventPosY: options.eventPosY || defaults.eventPosY
    });

    var index = hash.length - 1;
    $(this).bind('contextmenu', function(e) {
      // Check if onContextMenu() defined
      var bShowContext = (!!hash[index].onContextMenu) ? hash[index].onContextMenu(e) : true;
      if (bShowContext) { display(index, this, e, options); }
      return false;
    });
    return this;
  };

  function display(index, trigger, e, options) {
    var cur = hash[index];
    content = $('#'+cur.id).find('ul:first').clone(true);

    // Send the content to the menu
    menu.html(content);

    if (!!cur.onShowMenu) { menu = cur.onShowMenu(e, menu); }

    if( (e[cur.eventPosY] + menu.height()) > ($(window).height() + $(window).scrollTop()) ) {
      menu.css({'left':e[cur.eventPosX],'top':e[cur.eventPosY]-menu.height()});
    } else {
      menu.css({'left':e[cur.eventPosX],'top':e[cur.eventPosY]});
    }

    menu.show();

    $.each(cur.bindings, function(klass, func) {
      $('.'+klass, menu).bind('click', function(e) {
        hide();
        func(trigger, this);
        return false;
      });
    });

    $(document).one('click', function() {
      hide();
    });
  }

  function hide() {
    menu.hide();
  }

  // Apply defaults
  $.contextMenu = {
    defaults : function(userDefaults) {
      $.each(userDefaults, function(i, val) {
        if (typeof val == 'object' && defaults[i]) {
          $.extend(defaults[i], val);
        }
        else defaults[i] = val;
      });
    }
  };

})(jQuery);