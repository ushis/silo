# help.coffee
#
# Defines the jQuery siloHelp plugin.
do($ = jQuery) ->

  # Loads man pages and connects it with the elements.
  $.fn.siloHelp = (options) ->
    settings = $.extend {
      helpClass: 'need-help'
      helpText: '?'
    }, options

    @each ->
      el = $(@)
      url = $.silo.location('help', id: el.data('help'))

      $.ajax url: url, dataType: 'html', success: (help) =>
        help = $(help).siloOverlay()

        el.after ->
          btn = $('<div>', class: settings.helpClass, text: settings.helpText)
          btn.fadeIn(500).click -> help.trigger('show')
