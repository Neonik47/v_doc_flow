jQuery ->
  $("a[rel~=popover]").popover()
  $(".tooltip").tooltip()
  $("[rel~=tooltip]").tooltip({container:'body'})
  $('.dropdown-toggle').dropdown()
  $('select').selectpicker({container:'body'});


$ ->
  $('.datepicker').each (index, element) ->
    datepicker_element = $($(element).find('input'));
    datepicker_element.datepicker({autoclose: true, weekStart: 1, format: 'dd.mm.yyyy', language: 'ru'})
    $($(element).find('.input-group-addon')).click ->
      datepicker_element.datepicker('show')
