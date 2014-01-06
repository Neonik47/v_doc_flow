function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".field").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function remove_lines(link) {
  $(link).prev("input[type=text]").val("1");	
  $(link).prev(".line").html("yo");
  // $(link).closest(".fields").html("daa");//.hide();

  // $(link).offsetParent().html("woho");
  // alert(link);
  // $(link).prev("input[type=hidden]").val("1");
  // $(link).closest(".fields").hide();
}