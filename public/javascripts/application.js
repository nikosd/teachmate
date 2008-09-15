$(function() {

  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled");
  });

  $("#comments-box #my_comment a").bind("click", function(event) {
    $(this).parent().parent().empty();
    $("#edit_comment").show('slow');
    event.preventDefault();
  });

  $("a[@href*=show_comments]").bind("click", function(event) {
    $('#comments').show('slow');
    $(this).hide('slow');
    event.preventDefault();
  });

});
