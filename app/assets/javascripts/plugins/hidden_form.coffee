# hidden_form.coffee
#
# Defines the jQuery siloHiddenForm plugin.
do ($ = jQuery) ->

  # Connects an anchor with a hidden form.
  $.fn.siloHiddenForm = (options) ->
    settings = $.extend {
      abortClass: 'abort'
      submitClass: 'submit'
    }, options

    @each ->
      el = $(@).click -> false

      $.ajax url: el.attr('href'), dataType: 'html', success: (overlay) ->
        overlay = $(overlay).siloOverlay()
        form = overlay.find('form')
        form.find("input[name=#{$.silo.meta('csrf-param')}]").val($.silo.meta('csrf-token'))
        overlay.find(".#{settings.submitClass}").click -> form.submit()
        el.click -> overlay.trigger('show')
