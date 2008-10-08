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

  optional("mainpage initialization", $("input[@name=learn]"), function(obj) {
    var target = obj.offset();
    $("#mainpageLearnFieldHint").css("top", target.top - 140).css("left", target.left + 200);
    $("input[@name=learn]").focus(function(event) {
      if (!($.cookie('mainpageLearnFieldHint'))) {
        $("#mainpageLearnFieldHint").show();
      }
    });
  })

  optional("message form in user profile", $("#userMessageLink"), function(obj) {
    var target = obj.offset();
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
  })
  
  optional("hiding all hints", $(".hint img.close"), function(obj){
    obj.bind("click", function(event) {
      var target = $(this).parent().parent().parent()
      $(target).hide();
      $.cookie($(target).attr('id'), 'disable');
    });
  })



})
