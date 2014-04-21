# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
$->
  if $('.doc_show').lenght == 1
    $('[data-popover]').popover
      trigger: 'hover'
      delay: 500
      html: true
      container: 'body'
      placement: 'auto'
      content: () ->
        $($(this).data('popover')).html()

