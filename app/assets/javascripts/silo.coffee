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

  # Animates a toggle slide for the given selector
  $.fn.siloToggler = (selector, options) ->
    settings = $.extend {
      duration: 400
    }, options

    @each ->
      $(@).click ->
        $(selector).slideToggle(settings.duration)

  # Adds a delete confirmation field to the selector
  $.fn.siloConfirmDelete = (options) ->
    settings = $.extend {
      duration: 200
      confirmationClass: 'confirm-delete'
      deleteLabel: 'Delete'
      abortLabel: 'Abort'
    }, options

    @each ->
      $(@).click ->
        do (form = $(@).closest('form')) ->
          form.before ->
            do (box = $('<div>')) ->
              box.addClass(settings.confirmationClass).append ->
                $('<div>').text(settings.deleteLabel).click -> form.submit()
              .append ->
                $('<div>').text(settings.abortLabel).click -> 
                  box.fadeOut settings.duration, ->
                    box.remove()
              .fadeIn(settings.duration)
        false