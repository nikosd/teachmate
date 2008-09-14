$(function() {

  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled");
  });

  $("#comments-box #my_comment a").bind("click", function(event) {
    $(this).parent().parent().empty();
    $("#edit_comment").show('slow');
    event.preventDefault();
  });

});
