# master_box.coffee
#
# Defines the jQuery siloMasterBox plugin.
do ($ = jQuery) ->

  # Defines a master box and several slave boxes. If the master box is
  # checked, all slaves get checked too. If one slave is unchecked, the
  # master gets unchecked.
  $.fn.siloMasterBox = (options) ->
    settings = $.extend {
      masterClass: 'master'
      selector: 'input[type=checkbox]'
      hard: false
    }, options

    @each ->
      collection = $(@).find(settings.selector)
      masterClass = $(@).data('master-box') || settings.masterClass

      master = collection.filter(".#{masterClass}").change ->
        if $(@).is(':checked')
          collection.prop('checked', true)
        else if settings.hard
          collection.prop('checked', false)

      collection.not(".#{masterClass}").change ->
        master.prop('checked', false) if $(@).not(':checked')
