# autocomplete.coffee
#
# Defines the jQuery siloAutocomplete plugin.
do ($ = jQuery) ->

  # Downloads possible values and intializes comma separated autocompletion
  # for the connected text fields.
  $.fn.siloAutocomplete = (options) ->
    settings = $.extend {
      minLength: 0
    }, options

    @each ->
      el = $(@)
      url = $.silo.location(el.data('complete'), format: 'json')
      attribute = el.data('attribute')

      $.ajax url: url, dataType: 'json', success: (data) =>
        values = (record[attribute] for record in data)

        el.autocomplete
          minLength: settings.minLength
          appendTo: el.parent()
          source: (req, res) ->
            res($.ui.autocomplete.filter(values, req.term.split(/,\s*/).pop()))
          focus: -> false
          select: (e, ui) ->
            terms = @value.split(/,\s*/)
            terms.pop()
            terms.push(ui.item.value)
            terms.push('')
            @value = terms.join(', ')
            false
