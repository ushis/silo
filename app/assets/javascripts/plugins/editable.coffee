# editable.coffee
#
# Defines the siloEditable jQuery plugin.
do ($ = jQuery) ->

  # Handles editable buttons.
  $.fn.siloEditable = (options) ->
    return @ if @length is 0

    settings = $.extend {
      submitClass: 'submit'
      editorClass: 'editor'
      titleClass: 'title'
      types:
        string: '<input type="text">'
        text: '<textarea>'
    }, options

    collection = @click -> false
    url = $.silo.location('helpers.editable')

    $.ajax url: url, dataType: 'html', success: (dialog) ->
      dialog = $(dialog).siloOverlay()
      editor = dialog.find(".#{settings.editorClass}")
      title = dialog.find(".#{settings.titleClass}")

      dialog.find(".#{settings.submitClass}").click -> editor.submit()

      # Builds the input field.
      editor.prepare = (el) ->
        @data('el', el).attr('action', el.attr('href')).html ->
          input = $(settings.types[el.data('editable-type')])
          input.attr(name: el.data('prefix') + "[#{el.data('editable')}]")
          input.prop('autofocus', true)
          input.val(el.text())

      # Set the value and close the dialog on success.
      editor.on 'ajax:success', (_, data) ->
        el = editor.data('el')
        el.text(data[el.data('editable')])
        dialog.trigger('close')

      # Tell the user whats going on.
      editor.on 'ajax:error', (_, xhr) ->
        editor.find('.error').remove()
        editor.prepend($('<div>', class: 'error', text: xhr.responseText))

      # Prepare the editor and display the dialog.
      collection.click ->
        el = $(@)
        editor.prepare(el)
        title.text(el.data('name'))
        dialog.trigger('show')
