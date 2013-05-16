# toggle.coffe
#
# Implements the jQuery siloToggle plugin.
do ($ = jQuery) ->

  # Toggle a elements class on click.
  #
  # Removes the class on random document click.
  $.fn.siloToggle = ->
    el = $(@)
    klass = el.data('toggle')

    # Toggle class on click.
    @click (event) ->
      el.toggleClass(klass)
      event.stopPropagation()

    # Remove class on random document click.
    $(document).click ->
      el.removeClass(klass)
