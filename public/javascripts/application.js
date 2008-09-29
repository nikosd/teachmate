$(function() {

  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled").attr("value", "Please wait...");
  });

  $("#comments-box #my_comment a").bind("click", function(event) {
    $(this).parent().parent().empty();
    $("#edit_comment").show("slow");
    event.preventDefault();
  });

  $("a[@href*=show_comments]").bind("click", function(event) {
    $("#comments").show("slow");
    $(this).hide("slow");
    event.preventDefault();
  });

  $("a[@href^=/login]").toggle(
    function(event) {
      $("#loginbox").css("left", event.pageX - 10).css("top", event.pageY + 15).show("slow");
      event.preventDefault();
    },
    function(event) {
      $("#loginbox").fadeOut();
      event.preventDefault();
    }
  );
  
  $(".locationCaption span").bind("click", function(event) {
    $(this).parent().hide();
    $("#locationParams").show("slow");
  });

  // Hints location
  var target = $("input[@name=learn]").offset();
  $("#mainpageLearnFieldHint").css("top", target.top - 135).css("left", target.left + 300);
  $("input[@name=learn]").focus( function(event) {
    var hint = $("#mainpageLearnFieldHint");
    $(hint).show();
  })

})
