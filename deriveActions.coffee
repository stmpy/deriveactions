class deriveActions
  deriveActions: (data) ->
    data = @_parseResponse data unless typeof data is 'object'
    @[action]?(attrs) for action,attrs of data.actions if data.actions?
  redirect: (settings) ->
    settings.timeout ?= 2000
    window.setTimeout ->
      if settings.target?
        window.open settings.url, settings.target
      else if settings.url?
        window.location = settings.url
      else if settings.hash?
        window.location.hash = settings.hash
        window.location.reload()
    , settings.timeout
  _ajaxSettings:
    type: 'post'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      noty
        type: 'error',
        text: textStatus+' - '+errorThrown+': '+jqXHR.responseText,
        hide: false
    complete: (jqXHR, settings) ->
      @deriveActions jqXHR.responseJSON if jqXHR.responseJSON?
      noty jqXHR.responseJSON.noty if jqXHR.responseJSON.noty?
  _parseResponse: (string) ->
    try
      $.parseJSON string
    catch err
      console.warn 'data returned was not parseable json: '+err if window.console