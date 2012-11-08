# rails.coffee
#
# Mixes some custom behavior into $.rails
#
# =require jquery_ujs
do ($ = jQuery) ->

  # Everything we dont like about $.rails
  rails =

    # The first thing we dont like about $.rails is its blocking confirmation
    # handling. Lets make it non blocking.
    confirm: -> true

    # The second thing we dont like about $.rails is, that we cant pass
    # additional data to method links. The idea is to send data specified in
    # the HTML5 data attributes.
    #
    #   <a href="/controller/action" data-method="post" data-name="Hello"></a>
    #
    # A click on this link will trigger a POST request to "/controller/action"
    # with a "name=Hello" in the data string.
    handleMethod: (link) ->
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

  # Mix everything into $.rails
  $.extend($.rails, rails)
