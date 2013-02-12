# multi_select.coffee
#
# Defines several multi select related jQuery plugins.
do ($ = jQuery) ->

  # Handles groups in multi select boxes.
  $.fn.siloMultiSelectGroup = (options) ->
    settings = $.extend {
      groupClass: 'group'
      counterClass: 'counter'
    }, options

    @each ->
      el = $(@)
      el.accordion(heightStyle: 'content', active: el.data('active-group') || 0)

      el.find('ul').each ->
        ul = $(@)
        counter = ul.prev('h3').find(".#{settings.counterClass}")
        input = ul.find('input')

        ul.siloMasterBox(masterClass: settings.groupClass, hard: true)

        input.bind 'count', ->
          counter.text ->
            input.filter(":checked:not(.#{settings.groupClass})").length

        input.trigger('count').change -> $(@).trigger('count')

  # Handles the multi select box filter.
  $.fn.siloMultiSelectFilter = (options) ->
    settings = $.extend {
      minLength: 0
      filterSelector: 'input[type=text]'
      itemSelector: 'input[type=checkbox]'
    }, options

    @each ->
      el = $(@)
      filter = el.find(settings.filterSelector)
      items = el.find(settings.itemSelector).change -> el.trigger('update')
      values = ($(item).data('name') for item in items)

      # Collects all checked items and resets the filter value.
      el.bind 'update', ->
        names = ($(item).data('name') for item in items when item.checked)
        names.push('')
        filter.val(names.join(', '))

      # Collects all names from the filter and updates the items.
      filter.bind 'update', (_, newValue) ->
        names = @value.trim().split(/\s*,\s*/)
        names.push(newValue)
        items.prop 'checked', -> names.indexOf($(@).data('name')) > -1
        el.trigger('update')

      # Trigger the update event for the filter on submit.
      filter.closest('form').submit ->
        filter.trigger('update').autocomplete('close')
        return false

      # Inits the autocompletion.
      filter.autocomplete
        minLength: settings.minLength
        appendTo: filter.parent()
        focus: -> false
        source: (req, res) ->
          res($.ui.autocomplete.filter(values, req.term.split(/,\s*/).pop()))
        select: (_, ui) ->
          filter.trigger('update', [ui.item.value])
          return false

      el.trigger('update')

  # Handles a multi select overlay.
  $.fn.siloMultiSelectOverlay = (input, options) ->
    settings = $.extend {
      groupClass: 'group'
      submitClass: 'submit'
      selectClass: 'select'
    }, options

    @each ->
      el = $(@).siloOverlay()
      select = el.find(".#{settings.selectClass}")

      el.find(".#{settings.submitClass}").click ->
        el.trigger('submit').trigger('close')

      for id in $.trim(input.data('selected')).split(/\s+/)
        el.find("input[name=#{id}]").prop('checked', true)

      if select.data('grouped')
        select.siloMultiSelectGroup(settings)
      else if select.data('filtered')
        select.siloMultiSelectFilter(settings)

      hidden = $('<input>', name: input.attr('name'), type: 'hidden')
      input.removeAttr('name').after(hidden)

      # Collect all checked checkboxes and populate the input fields.
      el.bind 'submit', ->
        [ids, val] = [[], []]

        el.find("input:checked:not(.#{settings.groupClass})").each ->
          ids.push $(@).attr('name')
          val.push $(@).data('name')

        hidden.val ids.join(' ')
        input.val val.join(', ')

      el.trigger('submit')

  # Makes a text field multi selectable.
  $.fn.siloMultiSelect = (options) ->
    settings = $.extend {
      storagePrefix: 'multi-select-'
      filterSelector: 'input[type=text]'
    }, options

    @each ->
      el = $(@).prop('disabled', true)
      url = $.silo.location($(@).data('multi-select'))
      storageKey = settings.storagePrefix + el.attr('name')

      if el.attr('data-selected') && ! el.val().trim() && $.silo.hasStorage()
        el.val(localStorage[storageKey])

      el.closest('form').submit ->
        localStorage[storageKey] = el.val() if $.silo.hasStorage()

      $.ajax url: url, dataType: 'html', success: (select) ->
        select = $(select).siloMultiSelectOverlay(el, settings)

        el.prop('disabled', false).focus ->
          $(@).blur()
          select.trigger('show').find(settings.filterSelector).focus()
