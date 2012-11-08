# confirm.coffee
#
# Defines the jQuery siloConfirm plugin.
do ($ = jQuery) ->

  # Shows a simple confirmation dialog.
  $.fn.siloConfirm = (options) ->
    return @ if @length is 0

    settings = $.extend {
      submitClass: 'submit'
      abortClass: 'abort'
      confirmClass: 'confirmation'
      passwordClass: 'password'
    }, options

    collection = @click -> return false
    url = $.silo.location('helpers.confirm')

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
