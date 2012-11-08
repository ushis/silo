# overlay.coffee
#
# Defines the jQuery siloOverlay plugin.
do($ = jQuery) ->

  # Adds the overlay class to an element and bindes the "show" and the
  # "close" event.
  $.fn.siloOverlay = (options) ->
    settings = $.extend {
      overlayClass: 'overlay'
      abortClass: 'abort'
    }, options

    @each ->
      el = $(@).addClass(settings.overlayClass)
      el.bind 'show', -> $.silo.overlay(el)
      el.bind 'close', -> $.silo.closeOverlay()
      el.find(".#{settings.abortClass}").click -> el.trigger('close')
