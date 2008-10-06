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

  // Hints location and functions
  var target = $("input[@name=learn]").offset();
  $("#mainpageLearnFieldHint").css("top", target.top - 140).css("left", target.left + 200);
  $("input[@name=learn]").focus( function(event) {
//    alert($.cookie("mainpageLearnFieldHint"));
    if (!($.cookie('mainpageLearnFieldHint'))) {
      $("#mainpageLearnFieldHint").show();
    }
  })
  
  $(".hint img.close").bind("click", function(event) {
    var target = $(this).parent().parent().parent()
    $(target).hide();
    $.cookie($(target).attr('id'), 'disable');
  });

})
