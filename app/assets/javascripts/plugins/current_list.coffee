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
      @sync()

      @el.find('.open a').siloChooser success: (@select) =>
        @select.on 'ajax:success', 'a', (e, data) =>
          @set(data)
          @select.trigger('close')

    # Retrieves the current list from the server and updates the view.
    sync: ->
      url = $.silo.location('lists.current', format: 'json')
      $.ajax url, success: ((data) => @set(data)), error: (=> @set(null))

    # Binds ajax events to the syncro links.
    bindSynchronizer: (el) ->
      el.bind 'ajax:success', (e, data) => @set(data)
      el.bind 'ajax:error', => @set(null)

    # Updates the view.
    set: (list) ->
      list ||= {}
      @el.toggleClass('active', !! list.title)
      @title.attr('href', $.silo.location('lists.experts', id: list.id))
      @title.text(list.title)
      @updateItems(list)
      @updateOpeners(list)
      @updateTrackers(list)

    # Connects trackers with the current list.
    connectWithListTrackers: (collection) ->
      @listTrackers ||= $()
      @listTrackers = @listTrackers.add(collection)

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

      collection.click =>
        unless @el.hasClass('active')
          @select?.trigger('show')
          return false

    # Updates the list trackers.
    updateTrackers: (list) ->
      ids = {}
      title = @title

      @listTrackers?.each ->
        el = $(@).addClass('ready')
        type = el.data('item-type')
        current = el.find("[data-list-id=#{list.id}]")
        ids[type] ||= (obj.id for obj in list[type] || [])

        unless ids[type].indexOf(el.data('id')) > -1
          return current.hide()

        if current.length > 0
          return current.show()

        el.append ->
          href = $.silo.location(['lists', type], id: list.id)

          $("<#{el.data('list-tracker')}>", 'data-list-id': list.id).append ->
            $('<a>', href: href, text: title.text(), class: 'icon-list')

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

  # Connects a list tracker with the current list.
  $.fn.siloListTracker = -> CurrentList.connectWithListTrackers(@)
