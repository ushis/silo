# hidden_chosser.coffee
#
# Defines the jQuery siloHiddenChooser plugin.
do ($ = jQuery) ->

  # Fetches and opens a hidden chooser.
  $.fn.siloHiddenChooser = (options) ->
    @each ->
      el = $(@).click -> false

      $.ajax url: el.attr('href'), dataType: 'html', success: (overlay) ->
        overlay = $(overlay).siloOverlay()
        results = overlay.find('#results')
        results.on 'ajax:success', (_, html) -> $(html).siloFormOverlay().trigger('show')
        form = overlay.find('form')
        form.find("input[name=#{$.silo.meta('csrf-param')}]").val($.silo.meta('csrf-token'))
        form.find('input[type=text]').on 'input', $.silo.debounce((-> form.submit()), 300)
        form.on 'ajax:success', (_, html) -> results.html(html)
        el.click -> overlay.trigger('show')
