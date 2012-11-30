# application.coffee
#
# Boots the application.
#
# =require jquery
# =require jquery-ui
# =require rails
# =require silo
#
# =require_tree ./plugins
do ($ = jQuery) ->

  # Ban the evil browser.
  $.silo.redirectIE()

  # Disable links, marked as disabled.
  $(document).on 'click', 'a.disabled', -> false

  # Close layer on ESC.
  $(document).keyup (e) -> $.silo.closeOverlay() if e.keyCode is 27

  # Wait for the document before executing mission critical functions.
  $(document).ready ->

    # General stuff
    $('div.flash').siloFlash()
    $('a.hidden-form').siloHiddenForm()
    $('a.chooser').siloChooser()
    $('[data-help]').siloHelp()
    $('[data-master-box]').siloMasterBox()
    $('a[data-confirm]').siloConfirm()
    $('a[data-editable]').siloEditable()
    $('input[data-complete]').siloAutocomplete()
    $('input[data-multi-select]').siloMultiSelect()

    # Login
    $('#login-form').siloLogin()

    # Lists
    $('a.listable').siloListable()
    $('a.open-list').siloOpenList()
    $('[data-list-tracker]').siloListTracker()
    $('#current-list').siloCurrentList()
