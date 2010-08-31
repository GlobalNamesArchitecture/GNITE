$(document).ready(function(){ 
//If the User resizes the window, adjust the #container height
$(window).bind("resize", resizeWindow);
  function resizeWindow( e ) {
    var pHeight = $(document).height();   
    $("#navbar").css('height', pHeight);
  };
});
