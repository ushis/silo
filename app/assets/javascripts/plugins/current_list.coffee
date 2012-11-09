# current_list.coffee
#
# Defines several list realted jQuery plugins.
do ($ = jQuery) ->

  # Handles the current list. Use $.fn.siloCurrentList() to specify a
  # representation in the view.
  CurrentList =

    # Initializes the current list object and performs the initial sync.
    init: (@el) ->
      @title = @el.find('.title a')
      @open = @el.find('.open a').css(opacity: 0).click -> false
      url = $.silo.location('lists.current', 'json')

      $.ajax url, success: ((data) => @set(data)), error: (=> @set(null))

      $.ajax @open.attr('href'), dataType: 'html', success: (select) =>
        @select = $(select).siloSelectListOverlay()
        @open.animate(opacity: 1, 500).click => @select.trigger('show')

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

      collection.each ->
        el = $(@).append($('<div>', class: 'marker'))
        el.data('params', "ids=#{el.data('ids')}")

      collection.click =>
        unless @el.hasClass('active')
          @select?.trigger('show')
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

      @listItems?.each ->
        el = $(@).addClass('ready')
        type = el.data('item-type')
        ids[type] ||= (obj.id for obj in list[type] || [])

        active = $.trim(el.data('ids')).split(/\s+/).every (id) ->
          ids[type].indexOf(Number(id)) > -1

        el.toggleClass('active', active)
        el.data('method', if active then 'delete' else 'post')

  # Links an element with the current list.
  $.fn.siloCurrentList = -> CurrentList.init(@first()) if @length > 0

  # Connects a collection with the current list.
  $.fn.siloListable = -> CurrentList.connectWithListItems(@)

  # Turns a link into a "open this list" link.
  $.fn.siloOpenList = -> CurrentList.connectWithListOpeners(@)

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
        CurrentList.set(data)
        el.trigger('close')

      select.find('form.new').bind 'ajax:success', (e, data) ->
        CurrentList.set(data)
        el.trigger('close')
        $(@).get(0).reset()

      select.find('form.search').bind 'ajax:success', (e, data) ->
        table.html($(data).find(".#{settings.selectClass} table").html())
