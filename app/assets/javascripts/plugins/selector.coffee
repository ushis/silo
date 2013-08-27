# selector.coffee
#
# Defines the siloSelector jQuery plugin.
do ($ =jQuery) ->

  # Redirects to the selected id.
  $.fn.siloSelector = ->
    @each ->
      el = $(@).change ->
        params = {}
        params[el.attr('name')] = el.val()
        window.location = $.silo.replaceParams(el.data('selector'), params)
