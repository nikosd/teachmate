jQuery(function($) {
  
  var $DEBUG = !true
  
  var optional_exceptional = function(name, func){
    try {
      return func();
    } catch(e) {
      if ($DEBUG) alert(name + " failed due to:\n" + e)
      return null;
    }
  }

  var optional = function(name, obj, func){
    if (obj) {
      try {
        return func(obj);
      } catch(e) {
        if ($DEBUG) alert(name + " failed due to:\n" + e)
        return null;
      }
    } else {
      if ($DEBUG) alert(name + " failed due to:\n" + e)
      return null;
    }
  }


  $("form").submit(function() {
    $(":submit",this).attr("disabled", "disabled").attr("value", "Please wait...");
  });

  //enables buttons, when user clicks "back" button in browser
  $(":submit").attr("disabled", "")

  $("#comments-box #my_comment a").bind("click", function(event) {
    $(this).parent().parent().empty();
    $("#edit_comment").slideDown(500);
    event.preventDefault();
  });

  $("a[@href*=show_comments]").bind("click", function(event) {
    $("#comments").slideDown(500);
    $(this).hide();
    event.preventDefault();
  });

  $("a[@href^=/login]").toggle(
    function(event) {
      $("#loginbox-bgrnd").css("left", event.pageX - 10).css("top", event.pageY + 15).slideDown(500);
      $("#loginbox").css("left", event.pageX - 10).css("top", event.pageY + 15).slideDown(500);
      event.preventDefault();
    },
    function(event) {
      $("#loginbox").fadeOut();
      $("#loginbox-bgrnd").fadeOut();
      event.preventDefault();
    }
  );
  
  $(".locationCaption span").bind("click", function(event) {
    $(this).parent().hide();
    $("#locationParams").slideDown(500);
  });
  
  //hints

  optional("mainpage initialization", $("input[@name=learn]"), function(obj) {
    var target = obj.offset();
    $("#mainpageLearnFieldHint").css("top", target.top - 140).css("left", target.left + 200);
    $("input[@name=learn]").focus(function(event) {
      if (!($.cookie('mainpageLearnFieldHint'))) {
        $("#mainpageLearnFieldHint").fadeIn(500);
      }
    });
  })

  optional("comments in user profile hint", $("#comment-form textarea"), function(obj) {
    var target = obj.offset();
    $("#profileCommentHint").css("top", target.top - 140).css("left", target.left + 200);
    $("#comment-form textarea").focus(function(event) {
      if (!($.cookie('profileCommentHint'))) {
        $("#profileCommentHint").fadeIn(500);
      }
    });
  })

  optional("message form in user profile", $("#userMessageLink"), function(obj) {
    var target = obj.offset();
    $("#userMessageForm").css("top", target.top + 10).css("left", target.left + 100);
    $("#userMessageLink").bind("click", function(event) {
      if ($("#userMessageForm").is(":visible")) {
        $("#userMessageForm").fadeOut(300);
      }
      else {
        $("#userMessageForm").slideDown(500);
      }
      event.preventDefault();
    });
  })
  
  optional("hiding all hints", $(".hint img.close"), function(obj){
    obj.bind("click", function(event) {
      var target = $(this).parent().parent().parent()
      $(target).fadeOut(500);
      $.cookie($(target).attr('id'), 'disable', {expires: 356});
    });
  })



})
