# silo.coffee
#
# The main coffee script of the silo application.
#
# =require jquery
# =require jquery_ujs
# =require jquery-ui

# Checks the availability of localStorage. Returns true if localStorage
# is available, esle false.
hasStorage = -> !! window.localStorage

# Let's go
do($ = jQuery) ->

  # A simple layer.
  SiloLayer =
    layer: $('<div>').addClass('layer')

    fadeIn: (child) ->
      @child.detach() if @child
      @layer.appendTo('body').fadeIn(200)
      @child = child.appendTo('body').fadeIn(200)

    fadeOut: ->
      @layer.fadeOut(200, -> $(@).detach())
      @child.fadeOut(200, -> $(@).detach()) if @child

  # Adds the overlay class to an element and bindes the "show" and the
  # "close" event.
  $.fn.siloOverlay = (options) ->
    settings = $.extend {
      overlayClass: 'overlay'
      abortClass: 'abort'
    }, options

    @each ->
      el = $(@).addClass(settings.overlayClass)
      el.bind 'show', -> SiloLayer.fadeIn(el)
      el.bind 'close', -> SiloLayer.fadeOut()
      el.find(".#{settings.abortClass}").click -> el.trigger('close')

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

    @toggleClass settings.class, settings.duration, ->
      $(@).toggleClass settings.class, settings.duration

  # Disables links
  $.fn.siloDisabledLinks = -> @.click -> false

  # Defines a master box and several slave boxes. If the master box is
  # checked, all slaves get checked too. If one slave is unchecked, the
  # master gets unchecked.
  $.fn.siloMasterBox = (options) ->
    settings = $.extend {
      masterClass: 'master'
      hard: false
    }, options

    do (el = @) ->
      master = el.filter(".#{settings.masterClass}").change ->
        if $(@).is(':checked')
          el.prop('checked', true)
        else if settings.hard
          el.prop('checked', false)

      el.not(".#{settings.masterClass}").change ->
        master.prop('checked', false) if $(@).not(':checked')

  # Loads the specified help and connects it with an element.
  $.fn.siloHelp = (url, options) ->
    settings = $.extend {
      helpClass: 'need-help'
      helpText: '?'
    }, options

    do (collection = @) ->
      $.ajax url: url, dataType: 'html', success: (help) ->
        help = $(help).siloOverlay()

        collection.after ->
          $('<div>', class: settings.helpClass, text: settings.helpText)
          .fadeIn(500).click -> help.trigger('show')

  # Shows a simple confirmation dialog.
  $.fn.siloConfirm = (url, options) ->
    settings = $.extend {
      submitClass: 'submit'
      abortClass: 'abort'
      confirmClass: 'confirmation'
      passwordClass: 'password'
    }, options

    collection = @click -> return false

    $.ajax url: url, dataType: 'html', success: (dialog) ->
      dialog = $(dialog).siloOverlay()
      submit = dialog.find(".#{settings.submitClass}")
      password = dialog.find(".#{settings.passwordClass} input")
      confirmation = dialog.find(".#{settings.confirmClass}")

      collection.click ->
        oldSubmit = submit
        submit = $(@).clone().attr('class', oldSubmit.attr('class'))
        submit.click -> $(@).data(password: password.val())
        oldSubmit.replaceWith(submit)
        password.toggle( !! submit.data('password')).val(null)
        confirmation.text(submit.data('confirm'))
        dialog.trigger('show')

  # Handles groups in multi select boxes.
  $.fn.siloMultiSelectGroup = (options) ->
    settings = $.extend {
      activeGroup: 4
      groupClass: 'group'
      counterClass: 'counter'
    }, options

    @each ->
      el = $(@).accordion(autoHeight: false, active: settings.activeGroup)

      el.find('ul').each ->
        ul = $(@)
        counter = ul.prev('h3').find(".#{settings.counterClass}")
        input = ul.find('input')
        input.siloMasterBox(masterClass: settings.groupClass, hard: true)

        input.bind 'count', ->
          counter.text ->
            input.filter(":checked:not(.#{settings.groupClass})").length

        input.trigger('count').change -> $(@).trigger('count')

  # Handles a multi select overlay.
  $.fn.siloMultiSelectOverlay = (options) ->
    settings = $.extend {
      selected: []
      submitClass: 'submit'
      abortClass: 'abort'
      selectClass: 'select'
      grouped: false
    }, options

    # Connects the multi select overlay with an input field.
    @connectWith = (input, name) ->
      @each ->
        el = $(@)
        hidden = $('<input>').attr(name: name, type: 'hidden')
        input.after(hidden)

        el.bind 'submit', ->
          [ids, val] = [[], []]

          el.find("input:checked:not(.#{settings.groupClass})").each ->
            ids.push $(@).attr('name')
            val.push $(@).data('name')

          hidden.val ids.join(' ')
          input.val val.join(', ')

        el.trigger('submit')

    # Inits the overlay
    @each ->
      el = $(@).siloOverlay()

      el.find(".#{settings.submitClass}").click ->
        el.trigger('submit').trigger('close')

      for id in settings.selected
        el.find("input[name=#{id}]").prop('checked', true)

      if settings.grouped
        el.find(".#{settings.selectClass}").siloMultiSelectGroup(settings)

  # Makes a text field multi selectable.
  $.fn.siloMultiSelect = (name, url, options) ->
    settings = $.extend {
      groupClass: 'group'
      storagePrefix: 'multi-select-'
    }, options

    # Disable input while loading and prevent sending of the long text
    # values by submitting the form to avoid 414. Use localStorage instead.
    collection = @prop('disabled', true).each ->
      el = $(@)
      storageKey = settings.storagePrefix + el.attr('name')
      el.removeAttr('name')

      if settings.selected.length > 0 && ! el.val().trim() && hasStorage
        el.val(localStorage[storageKey])

      el.closest('form').submit ->
        localStorage[storageKey] = el.val() if hasStorage

    # Retrieve the multi select overlay and boot it up.
    $.ajax url: url, dataType: 'html', success: (select) ->
      select = $(select).siloMultiSelectOverlay(settings)
      collection.prop('disabled', false).focus -> select.trigger('show')
      collection.each -> select.connectWith($(@), name)


  # Connects an anchor with a list form.
  $.fn.siloListForm = (options) ->
    settings = $.extend {
      abortClass: 'abort'
      submitClass: 'submit'
    }, options

    csrfToken = $('meta[name=csrf-token]').attr('content')
    csrfParam = $('meta[name=csrf-param]').attr('content')

    @each ->
      el = $(@).click -> false

      $.ajax url: el.attr('href'), dataType: 'html', success: (overlay) ->
        overlay = $(overlay).siloOverlay()
        form = overlay.find('form')
        form.find("input[name=#{csrfParam}]").val(csrfToken)
        overlay.find(".#{settings.submitClass}").click -> form.submit()
        el.click -> overlay.trigger('show')

  # Downloads possible values and intializes comma separated autocompletion
  # for the connected text fields.
  $.fn.siloAutocomplete = (url, attribute, options) ->
    settings = $.extend {
      minLength: 0
    }, options

    $.ajax url: url, dataType: 'json', success: (data) =>
      values = (model[attribute] for model in data)

      @each ->
        $(@).autocomplete {
          minLength: settings.minLength
          appendTo: $(@).parent()
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
        }

  # Handles the current list. Use $.fn.siloCurrentList() to specify a
  # representation in the view.
  SiloCurrentList =

    # Initializes the current list object and performs the initial sync.
    init: (@el, url) ->
      @title = @el.find('.title a')
      @open = @el.find('.open a').css(opacity: 0).click -> false

      $.ajax url, success: ((data) => @set(data)), error: (=> @set(null))

      $.ajax @open.attr('href'), dataType: 'html', success: (select) =>
        @select = $(select).siloSelectListOverlay()
        @open.animate(opacity: 1, 500).click => @openSelect()

    # Opens the select overlay.
    openSelect: -> @select.trigger('show') if @select?

    # Binds ajax events to the syncro links.
    bindSynchronizer: (el) ->
      el.bind 'ajax:success', (e, data) => @set(data)
      el.bind 'ajax:error', => @set(null)

    # Connects some list openers with the current list.
    connectWithListOpeners: (collection) ->
      @listOpeners ||= $()
      @listOpeners = @listOpeners.add(collection)
      @bindSynchronizer(collection)

    # Connects a collection with the current list.
    connectWithListItems: (collection) ->
      @listItems ||= $()
      @listItems = @listItems.add(collection)
      @bindSynchronizer(collection)

      collection.append($('<div>', class: 'marker')).click =>
        unless @el.hasClass('active')
          @openSelect()
          return false

    # Updates the view.
    set: (list) ->
      list ||= {}
      @el.toggleClass('active', !! list.title)
      @title.text(list.title)
      @updateItems(list)
      @updateOpeners(list)

    # Updates all list openers.
    updateOpeners: (list) ->
      @listOpeners?.each ->
        $(@).toggleClass('active', Number($(@).data('id')) == list.id)

    # Updates the list items.
    updateItems: (list) ->
      ids = {}

      @listItems.each ->
        el = $(@).addClass('ready')
        type = el.data('item-type')
        ids[type] ||= (obj.id for obj in list[type] || [])
        active = $.inArray(Number(el.data('id')), ids[type]) > -1
        el.toggleClass('active', active)
        el.data('method', if active then 'delete' else 'put')

  # Links an element with the current list.
  $.fn.siloCurrentList = (url) -> SiloCurrentList.init(@first(), url)

  # Connects a collection with the current list.
  $.fn.siloListable = -> SiloCurrentList.connectWithListItems(@)

  # Turns a link into a "open this list" link.
  $.fn.siloOpenList = -> SiloCurrentList.connectWithListOpeners(@)

  # Handles the select list overlay.
  $.fn.siloSelectListOverlay = (options) ->
    settings = $.extend {
      abortClass: 'abort'
      selectClass: 'select'
    }, options

    @each ->
      el = $(@).siloOverlay()
      select = el.find(".#{settings.selectClass}")
      table = select.find('table')

      select.delegate '*', 'ajax:beforeSend', -> $(@).addClass('loading')
      select.delegate '*', 'ajax:complete', -> $(@).removeClass('loading')

      select.delegate 'a', 'ajax:success', (e, data) ->
        SiloCurrentList.set(data)
        el.trigger('close')

      select.find('form.new').bind 'ajax:success', (e, data) ->
        SiloCurrentList.set(data)
        el.trigger('close')
        $(@).get(0).reset()

      select.find('form.search').bind 'ajax:success', (e, data) ->
        table.html($(data).find(".#{settings.selectClass} table").html())

  # We use our own confirm dialog.
  $.rails.confirm = -> true

  # Override rails handleMethod, so that we can pass multiple hidden fields
  # through the links data.
  $.rails.handleMethod = (link) ->
    meta = $.extend {
      method: 'GET'
    }, link.data()

    if meta.method isnt 'GET'
      meta['_method'] = meta.method
      meta.method = 'POST'
      csrf_param = $('meta[name=csrf-param]').attr('content')
      meta[csrf_param] = $('meta[name=csrf-token]').attr('content')

    form = $('<form>',
      action: link.attr('href')
      method: meta.method
      'data-ujs-generated': true)

    delete(meta.method)

    for name, value of meta
      if name? && value?
        form.append $('<input>', type: 'hidden', name: name, value: value)

    form.hide().appendTo('body').submit()
