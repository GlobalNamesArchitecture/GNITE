
$.fn.spinner = function() {

  "use strict";

  if (this[0].spinnerElement) {
    return;
  }

  var position = this.css('position'), spinnerElement = $('<div class="spinner"></div>');

  if (position !== 'absolute' && position !== 'relative') {
    position = 'relative';
  }

  this.css('position', position).prepend(spinnerElement);

  spinnerElement.fadeIn('fast');

  return this.each(function () {
    this.spinnerElement = spinnerElement[0];
  });
};

$.fn.unspinner = function() {

  "use strict";

  this.each(function () {
    if (this.spinnerElement) {
      $(this.spinnerElement).fadeOut('fast', function() {
        $(this).remove();
      });

      this.spinnerElement = null;
    }
  });
  return this;
};