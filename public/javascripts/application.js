$(function() {

  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled").attr("value", "Please wait...");
  });

  //enables buttons, when user clicks "back" button in browser
  $(":submit").attr("disabled", "")

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
  
  //hints

  //mainpage hint
  var target = $("input[@name=learn]").offset();
  $("#mainpageLearnFieldHint").css("top", target.top - 140).css("left", target.left + 200);
  $("input[@name=learn]").focus(function(event) {
    if (!($.cookie('mainpageLearnFieldHint'))) {
      $("#mainpageLearnFieldHint").show();
    }
  });

  //message form in user profile
  var target = $("#userMessageLink").offset();
  $("#userMessageForm").css("top", target.top - 140).css("left", target.left + 200);
  $("#userMessageLink").toggle(
    function(event) {
      $("#userMessageForm").show();
      event.preventDefault();
    },
    function(event) {
      $("#userMessageForm").hide();
      event.preventDefault();
    }
  );

  // hiding all hints
  $(".hint img.close").bind("click", function(event) {
    var target = $(this).parent().parent().parent()
    $(target).hide();
    $.cookie($(target).attr('id'), 'disable');
  });




})
