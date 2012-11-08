# flash.coffee
#
# Defines the jQuery siloFlash plugin.
do ($ = jQuery) ->

  # Animates the flash message to a certain CSS class and back.
  $.fn.siloFlash = (options) ->
    settings = $.extend {
      class: 'highlight'
      duration: 400
    }, options

    @toggleClass settings.class, settings.duration, ->
      $(@).toggleClass settings.class, settings.duration
