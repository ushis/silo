# chooser.coffee
#
# Defines the siloChooser jQuery plugin.
do ($ = jQuery) ->

  # Handles a chooser dialog.
  $.fn.siloChooser = (options) ->
    settings = $.extend {
      success: null
      maxResults: 10
      filterSelector: 'input[type=text]'
      resultSelector: 'tbody'
      itemSelector: 'tr'
    }, options

    @each ->
      el = $(@).click -> false

      $.ajax url: el.attr('href'), dataType: 'html', success: (overlay) ->
        overlay = $(overlay).siloOverlay()
        filter = overlay.find(settings.filterSelector)
        result = overlay.find(settings.resultSelector)

        el.click ->
          overlay.trigger('show')
          filter.focus()

        items = result.find(settings.itemSelector).map (_, item) ->
          item = el: $(item)
          item.index = item.el.data('index').trim().toLowerCase()
          item

        filter.bind 'input', $.silo.debounce ->
          value = @value.trim().toLowerCase()
          hits = []

          for item in items
            if item.index.indexOf(value) > -1
              hits.push(item.el)
              break if hits.length is settings.maxResults

          result.html(hits)

        filter.trigger('input')
        filter.closest('form').submit -> false

        settings.success(overlay) if settings.success
