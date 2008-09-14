$(function() {

  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled");
  });


});
