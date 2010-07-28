// clear inputs with starter values
new function($) {
  $.fn.prefilledInput = function() {

    var focus = function () {
      $(this).removeClass('prefilled');
      if (this.value == this.prefilledValue) {
        this.value = '';
      }
    };

    var blur = function () {
      if (this.value == '') {
        $(this).addClass('prefilled').val(this.prefilledValue);
      } else if (this.value != this.prefilledValue) {
        $(this).removeClass('prefilled');
      }
    };

    var extractPrefilledValue = function () {
      if (this.title) {
        this.prefilledValue = this.title;
        this.title = '';
      } else if (this.id) {
        this.prefilledValue = $('label[for=' + this.id + ']').hide().text();
      }
    };

    var initialize = function (index) {
      if (!this.prefilledValue) {
        this.extractPrefilledValue = extractPrefilledValue;
        this.extractPrefilledValue();
        $(this).trigger('blur');
      }
    };

    return this.filter(":input").
      focus(focus).
      blur(blur).
      each(initialize);
  };

  var clearPrefilledInputs = function () {
    $(this).find("input.prefilled").val("");
  };

  var prefilledSetup = function () {
    $('input.prefilled').prefilledInput();
    $('form').submit(clearPrefilledInputs);
  };

  $(document).ready(prefilledSetup);
}(jQuery);
