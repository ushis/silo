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
    $('a[data-confirm]').siloConfirm()
    $('[data-master-box]').siloMasterBox()

    # Login
    $('#login-form').siloLogin()

    # Lists
    $('a.listable').siloListable()
    $('a.open-list').siloOpenList()
    $('#current-list').siloCurrentList()

    # Autocomplete
    $('input[data-complete]').siloAutocomplete()

    # Multi select
    $('input[data-multi-select]').siloMultiSelect()

    # Help
    $('[data-help]').siloHelp()
