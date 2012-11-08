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
      el.accordion(autoHeight: false, active: el.data('active-group') || 0)

      el.find('ul').each ->
        ul = $(@)
        counter = ul.prev('h3').find(".#{settings.counterClass}")
        input = ul.find('input')

        ul.siloMasterBox(masterClass: settings.groupClass, hard: true)

        input.bind 'count', ->
          counter.text ->
            input.filter(":checked:not(.#{settings.groupClass})").length

        input.trigger('count').change -> $(@).trigger('count')

  # Handles a multi select overlay.
  $.fn.siloMultiSelectOverlay = (input, options) ->
    settings = $.extend {
      submitClass: 'submit'
      selectClass: 'select'
    }, options

    @each ->
      el = $(@).siloOverlay()

      el.find(".#{settings.submitClass}").click ->
        el.trigger('submit').trigger('close')

      for id in $.trim(input.data('selected')).split(/\s+/)
        el.find("input[name=#{id}]").prop('checked', true)

      if input.data('grouped')
        el.find(".#{settings.selectClass}").siloMultiSelectGroup(settings)

      hidden = $('<input>', name: input.data('multi-select'), type: 'hidden')
      input.after(hidden)

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
    }, options

    @each ->
      el = $(@).prop('disabled', true)
      url = $.silo.location($(@).data('multi-select'))
      storageKey = settings.storagePrefix + el.attr('name')

      el.removeAttr('name')

      if el.attr('data-selected') && ! el.val().trim() && $.silo.hasStorage()
        el.val(localStorage[storageKey])

      el.closest('form').submit ->
        localStorage[storageKey] = el.val() if $.silo.hasStorage()

      $.ajax url: url, dataType: 'html', success: (select) ->
        select = $(select).siloMultiSelectOverlay(el, settings)

        el.prop('disabled', false).focus ->
          $(@).blur()
          select.trigger('show')
