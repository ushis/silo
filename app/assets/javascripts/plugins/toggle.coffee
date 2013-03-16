# toggle.coffe
#
# Implements the jQuery siloToggle plugin.
do ($ = jQuery) ->

  # Toggle a elements class on click.
  #
  # Removes the class on random document click.
  $.fn.siloToggle = ->

    # Toggle class on click.
    @click (event) ->
      el = $(@)
      klass = el.data('toggle')
      el.toggleClass(klass)
      event.stopPropagation()

      # Remove class on random document click.
      $(document).click ->
        el.removeClass(klass)
        $(@).unbind('click')
