# login.coffee
#
# Defines the jQuery siloLogin plugin.
do ($ = jQuery) ->

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
        localStorage.username = username.val() if $.silo.hasStorage()

      if $.silo.hasStorage() and localStorage.username
        username.val(localStorage.username)

      if username.val().trim().length > 0
        password.focus()
      else
        username.focus()
