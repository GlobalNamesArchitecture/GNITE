$(document).ready(function() {
  $('#browse-gnaclr-button').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('.ajax-load-new-tab').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('.gnaclr_classification_show').live('click', function() {
    var url = $(this).attr("href");
    $('#new-tab').load(url);
    return false;
  });

  $('#import-gnaclr-button').live('click', function() {
    $('#gnaclr-description').append('<div class="spinner" />');

    $.post('/gnaclr_imports', { master_tree_id : $('#tree-container').attr('data-database-id'), title : $('#gnaclr-description h2').text(), url : $(this).attr('data-tree-url') }, function(response) {
      var tree_id = response.tree_id;

      var interval = setInterval(function() {
        $.get('/reference_trees/' + tree_id, function(response, status, xhr) {
          if (xhr.status == 200) {
            $('.spinner').remove();
            $('#tab-titles li:last').prev().prepend($('<li />').append($('<a />', { href : '#' + response.domid, text : response.title }))) ;
            $('#new-tab').prepend(response.tree);
          }
          if (xhr.status == 200 || xhr.status == 204) {
            clearInterval(interval);
          }
        }, 'json');
      }, 1999);
    }, 'json');
  });
});
