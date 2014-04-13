// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.

//= require jquery
//= require jquery_ujs
//= require_tree .
//= require bootstrap
//= require jquery.tokeninput


// function remove_fields(link) {
//   $(link).previous("input[type=hidden]").value = "1";
//   $(link).up(".fields").hide();
// }

// function add_fields(link, association, content) {
//   var new_id = new Date().getTime();
//   var regexp = new RegExp("new_" + association, "g")
//   $(link).up().insert({
//     before: content.replace(regexp, new_id)
//   });
// }

function get_fields_json(type_id){
  $.ajax({
    url:      '/doc_types/' + type_id + '/get_lines.json', // адрес для получения наших данных
    type:     'GET',                               // указан для наглядности, по-умолчанию и так GET
    dataType: 'json'                               // мы ждём в ответ json
  })
  .done(function(data){
    var str = "";
    $.each(data, function(i, val){ // http://api.jquery.com/jQuery.each/
      // i - индекс в массиве. Нам он не нужен.
      // val - элемент массива, объект, содержащий в себе поля объекта Line
      str += '<option value="' + val.id + '">' + val.name + '</option>';
    });
    $('#right_place').html(str);
  })
  .fail(function(){
    alert("ajax failed!");  // обработчик провальных ситуаций
  });
}

function get_fields(type_id){
  $( "#doc_type_lines" ).load( '/doc_types/' + type_id + '/get_lines' );
}

$('#doc_doc_type_id').change(function(){
  get_fields($(this).val());
}).change();

$(function() {
  $("#chat_room_member_tokens").tokenInput("/users.json", {
    crossDomain: false,
    tokenValue: "id",
    prePopulate: $("#chat_room_member_tokens").data("pre"),
    theme: "facebook"
  });
});
