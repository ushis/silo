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
    }, options

    do (el = $(@)) ->
      do (master = el.filter(".#{settings.masterClass}")) ->
        master.change ->
          el.prop('checked', true) if $(@).is(':checked')
        el.not(".#{settings.masterClass}").change ->
          master.prop('checked', false) if $(@).not(':checked')

  # Represents a multi select field.
  class SiloMultiSelect
    constructor: (@name, @el) ->
      @hidden = []

    # Removes all hidden fields, resets the value.
    clear: ->
      for field in @hidden
        field.remove()
      @hidden = []
      @el.val('')

    # Creates new hidden fields and sets the value.
    setValues: (values) ->
      @clear()
      val = []
      for v in values
        val.push v[1]
        @newHidden v[0]
      @el.val(val.join(', '))

    # Creates a new hidden field.
    newHidden: (id) ->
      h = $('<input>').attr(name: @name, type: 'hidden', value: id)
      @hidden.push h
      @el.before h

  # Represents an overlay multi select box.
  class SiloMultiSelectBox
    constructor: (@multiSelect, @s) ->
      @layer = new SiloLayer(@s.layerClass)
      @wrapper = $('<div>').addClass(@s.wrapperClass)
      @header = $('<div>').addClass(@s.headerClass).text(@s.headline)
      @abort = $('<div>').addClass("#{@s.abortClass} #{@s.buttonClass}").text(@s.abortText)
      @submit = $('<div>').addClass("#{@s.submitClass} #{@s.buttonClass}").text(@s.submitText)
      @select = $('<div>').addClass(@s.selectClass)
      @header.append(@submit, @abort)
      @wrapper.append(@header, @select)

      do (wrapper = @wrapper, layer = @layer, abort = @abort) ->
        abort.click ->
          layer.fadeOut()
          wrapper.fadeOut 200, ->
            wrapper.detach()

      do (abort = @abort, submit = @submit, select = @select, multiSelect = @multiSelect) ->
        submit.click ->
          values = []
          select.find('input:checked').each ->
            do (input = $(@)) ->
              values.push([input.attr('id'), input.data('name')])
          multiSelect.setValues(values)
          abort.click()

    # Populates the mutli select field with check boxes.
    populate: (selected) ->
      do (s = @s, select = @select) ->
        for i in [0..s.cols - 1]
          ul = $('<ul>')
          start = i * s.per_col
          end = start + s.per_col - 1
          for j in [start..end]
            break if j >= s.data.length
            id = s.data[j][1]
            name = s.data[j][0]
            input = $('<input>').attr(id: id, name: id, type: 'checkbox')
            input.data('name', name).prop 'checked', ->
              $.inArray(String(id), selected) > -1
            label = $('<label>').attr(for: id).text(name)
            ul.append ->
              $('<li>').append(input, label)
          select.append(ul)

    # Fades in.
    fadeIn: ->
      @layer.fadeIn()
      do (wrapper = @wrapper) ->
        $('body').append ->
          wrapper.fadeIn(200)

  # Makes a text field multi selectable.
  $.fn.siloMultiSelect = (name, selected, data, options) ->
    settings = $.extend {
      cols: 6
      layerClass: 'layer'
      wrapperClass: 'multi-select'
      headerClass: 'header'
      selectClass: 'select'
      headline: 'Multi Select'
      submitClass: 'submit'
      submitText: 'Submit'
      abortClass: 'abort'
      abortText: 'Abort'
      buttonClass: 'button'
    }, options

    settings.per_col = Math.ceil(data.length / settings.cols)
    settings.data = data
    settings.map = {}

    for lang in data
      settings.map[lang[1]] = lang[0]

    @each ->
      do (el = $(@)) ->
        multiSelect = new SiloMultiSelect(name, el)
        multiSelect.setValues([id, settings.map[id]] for id in selected)
        multiSelectBox = new SiloMultiSelectBox(multiSelect, settings)
        multiSelectBox.populate(selected)
        el.focus ->
          multiSelectBox.fadeIn()
