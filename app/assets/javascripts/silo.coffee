# silo.coffee
#
# The main coffee script of the silo application.
#
# =require jquery
# =require jquery-ui

# Checks the availability of localStorage. Returns true if localStorage
# is available, esle false.
hasStorage = ->
  !!window.localStorage

# Let's go
do($ = jQuery) ->

  # A simple layer.
  class SiloLayer
    constructor: (className) ->
      @layer = $('<div>').addClass(className)

    # Fades in.
    fadeIn: ->
      @layer.appendTo('body').fadeIn(200)

    # Fades out.
    fadeOut: ->
      @layer.fadeOut 200, ->
        $(@).detach()

  # Writes the username to localStorage on submit and sets the focus
  # to the first empty input field.
  $.fn.siloLogin = (options) ->
    settings = $.extend {
      username: 'input[name=username]'
      password: 'input[name=password]'
    }, options

    @each ->
      username = $(@).find(settings.username)
      password = $(@).find(settings.password)

      $(@).submit ->
        localStorage.username = username.val() if hasStorage

      if hasStorage and localStorage.username
        username.val(localStorage.username)

      if username.val().trim().length > 0
        password.focus()
      else
        username.focus()

  # Animates the flash message to a certain CSS class and back.
  $.fn.siloFlash = (options) ->
    settings = $.extend {
      class: 'highlight'
      duration: 400
    }, options

    @each ->
      do(el = $(@)) ->
        el.toggleClass settings.class, settings.duration, ->
          el.toggleClass settings.class, settings.duration

  # Disables links
  $.fn.siloDisabledLinks = ->
    @each -> $(@).click -> false

  # Animates a toggle slide for the given selector.
  $.fn.siloToggler = (selector, options) ->
    settings = $.extend {
      duration: 400
    }, options

    @each ->
      $(@).click ->
        $(selector).slideToggle(settings.duration)

  # Wraps adds a click away x the all elements.
  $.fn.siloClickAway = (options) ->
    settings = $.extend {
      text: 'x'
      class: 'delete'
      divClass: 'click-away'
    }, options

    @each ->
      $(@).wrap('<div>').parent().addClass(settings.divClass).append ->
        $('<span>').addClass(settings.class).text(settings.text).click ->
          do (el = $(@).closest('div')) ->
            if el.parent().children("div.#{settings.divClass}").length > 1
              el.remove()

  # Adds a click and clone + to an element.
  $.fn.siloClickAndClone = (options) ->
    settings = $.extend {
      text: 'more'
      class: 'more'
      selector: 'div.click-away'
    }, options

    @each ->
      do (el = $(@)) ->
        el.append ->
          $('<span>').addClass(settings.class).text(settings.text).click ->
            $(@).before ->
              el.find(settings.selector).last().clone(true)

  # Defines a master box and several slave boxes. If the master box is
  # checked, all slaves get checked too. If one slave is unchecked, the
  # master gets unchecked.
  $.fn.siloMasterBox = (options) ->
    settings = $.extend {
      masterClass: 'master'
      hard: false
    }, options

    do (el = $(@)) ->
      do (master = el.filter(".#{settings.masterClass}")) ->
        master.change ->
          if $(@).is(':checked')
            el.prop('checked', true)
          else if settings.hard
            el.prop('checked', false)
        el.not(".#{settings.masterClass}").change ->
          master.prop('checked', false) if $(@).not(':checked')
        return el

  # Shows a simple confirmation dialog.
  $.fn.siloConfirmDelete = (options) ->
    settings = $.extend {
      layerClass: 'layer'
      buttonClass: 'button'
      submitClass: 'submit'
      submitText: 'Ok'
      abortClass: 'abort'
      abortText: 'Abort'
      textClass: 'text'
      headerClass: 'header'
      headerText: 'Are you sure?'
      wrapperClass: 'confirm-delete'
    }, options

    makeBox = (type) ->
      $('<div>').addClass(settings["#{type}Class"])

    makeButton = (type) ->
      [klass, text] = [settings["#{type}Class"], settings["#{type}Text"]]
      $('<div>').addClass("#{settings.buttonClass} #{klass}").text(text)

    layer = new SiloLayer(settings.layerClass)

    @each ->
      do (el = $(@)) ->
        el.click ->
          dialog = makeBox('wrapper')
          dialog.append ->
            makeBox('header').append ->
              $('<h2>').text(settings.headerText)
            .append ->
              makeButton('submit').click ->
                el.closest('form').submit()
            .append ->
              makeButton('abort').click ->
                layer.fadeOut()
                dialog.fadeOut 200, ->
                  dialog.remove()
          .append ->
            makeBox('text').text(el.data('confirm'))
          .appendTo('body').fadeIn(200)
          layer.fadeIn()
          return false

  # Represents a multi select field.
  class SiloMultiSelect
    constructor: (name, @el) ->
      @hidden = $('<input>').attr(name: name, type: 'hidden')
      @el.after @hidden

    # Creates new hidden fields and sets the value.
    setValues: (values) ->
      [ids, val] = [[], []]
      for v in values
        ids.push v[0]
        val.push v[1]
      @hidden.val ids.join(' ')
      @el.val val.join(', ')

  # Represents an overlay multi select box.
  class SiloMultiSelectBox
    constructor: (@multiSelect, s) ->
      makeBox = (type) ->
        $('<div>').addClass(s["#{type}Class"])
      makeButton = (type) ->
        makeBox(type).addClass(s.buttonClass).text(s["#{type}Text"])

      abort = makeButton('abort')
      submit = makeButton('submit')
      select = makeBox('select')
      @layer = new SiloLayer(s.layerClass)
      @wrapper = makeBox('wrapper').append(select).prepend ->
        makeBox('header').append(submit, abort).prepend ->
          $('<h2>').text(s.headline)

      do (wrapper = @wrapper, layer = @layer) ->
        abort.click ->
          layer.fadeOut()
          wrapper.fadeOut 200, ->
            wrapper.detach()

      do (multiSelect = @multiSelect) ->
        submit.click ->
          values = []
          select.find('input:checked').not('.group').each ->
            do (input = $(@)) ->
              values.push([input.attr('id'), input.data('name')])
          multiSelect.setValues(values)
          abort.click()

      do ->
        appendGroupHeader = (text) ->
          select.append ->
            $('<h3>').append ->
              $('<a>').attr(href: '#').text(text).append ->
                $('<span>')

        appendGroup = (group) ->
          select.append(group)
          do (counter = group.prev('h3').find('a span')) ->
            do (inputs = group.find('input')) ->
              inputs.siloMasterBox(masterClass: 'group', hard: true)
              .bind 'commit', ->
                counter.text(inputs.filter(':checked:not(.group)').length)
              .change ->
                $(@).trigger('commit')

        groupUl = (i) ->
          $('<ul>').append ->
            $('<li>').append ->
              $('<input>').attr(id: "g-#{i}", type: 'checkbox', class: 'group')
            .append ->
              $('<label>').attr(for: "g-#{i}").text(s.allText)

        appendCol = (groupUl, col) ->
          groupUl.append ->
            $('<li>').addClass('col').append(col)

        appendItem = (col, item) ->
          col.append ->
            $('<li>').addClass('item').append ->
              $('<input>')
                .attr(id: item[1], name: item[1], type: 'checkbox')
                .data('name', item[0]).prop 'checked', ->
                  $.inArray(String(item[1]), s.selected) > -1
            .append ->
              $('<label>').attr(for: item[1]).text(item[0])

        appendItems = (groupUl, items) ->
          per_col = Math.ceil(items.length / s.cols)
          for j in [0..s.cols - 1]
            ul = $('<ul>')
            start = j * per_col
            end = start + per_col - 1
            for item in items[start..end]
              appendItem(ul, item)
            appendCol(groupUl, ul)

        if ! s.grouped
          gUl = $('<ul>')
          appendItems(gUl, s.data)
          appendGroup(gUl)
        else
          for group, i in s.data
            appendGroupHeader(group[0])
            gUl = groupUl(i)
            appendItems(gUl, group[1])
            appendGroup(gUl)
          select.accordion(
            header: 'h3',
            autoHeight: false,
            active: s.activeGroup
          ).find('input').trigger('commit')
        submit.click()

    # Fades in.
    fadeIn: ->
      @layer.fadeIn()
      do (wrapper = @wrapper) ->
        $('body').append ->
          wrapper.fadeIn(200)

  # Makes a text field multi selectable.
  $.fn.siloMultiSelect = (name, url, options) ->
    settings = $.extend {
      cols: 6
      grouped: true
      selected: []
      activeGroup: 3
      layerClass: 'layer'
      wrapperClass: 'multi-select'
      headerClass: 'header'
      selectClass: 'select'
      headline: 'Multi Select'
      allText: 'All'
      submitClass: 'submit'
      submitText: 'Submit'
      abortClass: 'abort'
      abortText: 'Abort'
      buttonClass: 'button'
      storagePrefix: 'multi-select-'
    }, options

    do (collection = @) ->
      mapData = (data) ->
        settings.map = {} unless settings.map
        for item in data
          settings.map[item[1]] = item[0]

      ready = (data) ->
        settings.data = data
        if ! settings.grouped
          mapData(data)
        else
          for group in data
            mapData(group[1])

        collection.each ->
          do (el = $(@)) ->
            multiSelect = new SiloMultiSelect(name, el)
            multiSelectBox = new SiloMultiSelectBox(multiSelect, settings)
            el.focus ->
              multiSelectBox.fadeIn()

      $.ajax(url: url, dataType: 'json', success: ready)

    # Do not send the country/language names to avoid 414 errors.
    # Just cache them in localStorage if possible.
    @each ->
      do (el = $(@)) ->
        storageKey = settings.storagePrefix + el.attr('name')
        if settings.selected.length > 0 && hasStorage
          el.val(localStorage[storageKey])
        el.closest('form').submit ->
          localStorage[storageKey] = el.val() if hasStorage
          el.prop('disabled', true)
