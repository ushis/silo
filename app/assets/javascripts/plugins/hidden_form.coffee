# hidden_form.coffee
#
# Defines the jQuery siloHiddenForm plugin.
do ($ = jQuery) ->

  # Form overlay plugin.
  $.fn.siloFormOverlay = (options) ->
    settings = $.extend {
      submitClass: 'submit'
    }, options

    @each ->
      overlay = $(@).siloOverlay()
      form = overlay.find('form')
      form.find("input[name=#{$.silo.meta('csrf-param')}]").val($.silo.meta('csrf-token'))
      overlay.find(".#{settings.submitClass}").click -> form.submit()


  # Connects an anchor with a hidden form.
  $.fn.siloHiddenForm = (options) ->
    @each ->
      el = $(@).click -> false

      $.ajax url: el.attr('href'), dataType: 'html', success: (overlay) ->
        overlay = $(overlay).siloFormOverlay(options)
        el.click -> overlay.trigger('show')
