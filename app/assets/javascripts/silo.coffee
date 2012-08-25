# silo.coffee
#
# The main coffee script of the silo application.
#
# =require jquery
# =require jquery-ui

# Checks the availability of localStorage. Returns true if localStorage
# is available, esle false.
hasStorage = -> !! window.localStorage

# Let's go
do($ = jQuery) ->

  # A simple layer.
  SiloLayer =
    layer: $('<div>').addClass('layer')
    fadeIn: -> @layer.appendTo('body').fadeIn(200)
    fadeOut: -> @layer.fadeOut 200, -> $(@).detach()

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
  $.fn.siloDisabledLinks = -> @.click -> false

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

  # Loads the specified help and connects it with an element.
  $.fn.siloHelp = (url, options) ->
    settings = $.extend {
      helpClass: 'need-help'
      helpText: '?'
    }, options

    do (collection = @) ->
      ready = (help) ->
        help = $(help)
        help.find('div.button').click ->
          SiloLayer.fadeOut()
          help.fadeOut(200)
        $('body').append(help)
        collection.after ->
          $('<div>').addClass(settings.helpClass).text(settings.helpText)
          .fadeIn(600).click ->
            SiloLayer.fadeIn()
            help.fadeIn(200)

      $.ajax(url: url, dataType: 'html', success: ready)

  # Shows a simple confirmation dialog.
  $.fn.siloConfirmDelete = (options) ->
    settings = $.extend {
      buttonClass: 'button'
      submitClass: 'submit'
      submitText: 'Ok'
      abortClass: 'abort'
      abortText: 'Abort'
      textClass: 'text'
      headerClass: 'header'
      headerText: 'Are you sure?'
      wrapperClass: 'confirm-delete overlay'
      passwordClass: 'password'
      passwordText: 'Confirm with your password.'
    }, options

    makeBox = (type) ->
      $('<div>').addClass(settings["#{type}Class"])

    makeButton = (type) ->
      [klass, text] = [settings["#{type}Class"], settings["#{type}Text"]]
      $('<div>').addClass("#{settings.buttonClass} #{klass}").text(text)

    makePassword = ->
      $('<input>').attr {
        name: 'password'
        type: 'password'
        placeholder: settings.passwordText
      }

    @each ->
      do (el = $(@)) ->
        el.click ->
          dialog = makeBox('wrapper')
          password = makePassword()
          submit = makeButton('submit').click ->
            el.closest('form').append(password.clone()).submit()
          abort = makeButton('abort').click ->
            SiloLayer.fadeOut()
            dialog.fadeOut 200, ->
              dialog.remove()
          dialog.append ->
            makeBox('header').append ->
              $('<h2>').text(settings.headerText)
            .append(submit, abort)
          .append ->
            makeBox('text').text(el.data('confirm'))
          if el.hasClass(settings.passwordClass)
            dialog.append ->
              makeBox('password').append(password)
          dialog.appendTo('body').fadeIn(200)
          SiloLayer.fadeIn()
          false

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

  # Makes a text field multi selectable.
  $.fn.siloMultiSelect = (name, url, options) ->
    settings = $.extend {
      selected: []
      submitClass: 'submit'
      abortClass: 'abort'
      selectClass: 'select'
      counterClass: 'counter'
      grouped: false
      groupClass: 'group'
      activeGroup: 4
      storagePrefix: 'multi-select-'
    }, options

    prepareSelect = (el) ->
      do (el = $(el)) ->
        for id in settings.selected
          el.find("input[name=#{id}]").prop('checked', true)

        if settings.grouped
          el.find(".#{settings.selectClass}")
            .accordion(autoHeight: false, active: settings.activeGroup)
          .find('ul').each ->
            counter = $(@).prev('h3').find(".#{settings.counterClass}")
            input = $(@).find('input')
              .siloMasterBox(masterClass: settings.groupClass, hard: true)
            input.bind 'count', ->
              counter.text ->
                input.filter(":checked:not(.#{settings.groupClass})").length
            .trigger('count').change -> $(@).trigger('count')

        el.find(".#{settings.abortClass}").click -> el.trigger('close')
        el.find(".#{settings.submitClass}").click -> el.trigger('submit')

        el.bind 'close', ->
          SiloLayer.fadeOut()
          el.fadeOut 200, -> el.detach()
        .bind 'show', ->
          SiloLayer.fadeIn()
          el.appendTo('body').fadeIn(200)

    do (collection = @) ->
      ready = (select) ->
        select = prepareSelect(select)

        collection.each ->
          do (el = $(@)) ->
            el.focus -> select.trigger('show')
            multiSelect = new SiloMultiSelect(name, el)

            select.submit ->
              values = []
              select.find("input:checked:not(.#{settings.groupClass})").each ->
                values.push [$(@).attr('name'), $(@).data('name')]
              multiSelect.setValues(values)
              select.trigger('close')
            .trigger('submit')

      $.ajax(url: url, dataType: 'html', success: ready)

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
