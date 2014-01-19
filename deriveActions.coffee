###
# @author Travis Jeppson <travis@plaidtie.net>
# @depends jQuery
###
class DeriveActions
  deriveActions: (data) ->
    data = @parseResponse data unless _.isObject(data)
    return unless data? # exit if parseResponse is unsuccessfull
    @[action]?(attrs) for action,attrs of data.actions when data.actions?

  # Redirection
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

  # Reloading sections
  reload: (sections) ->
    # trigger reload
    $('#'+id).trigger('reload.deriveActions') for id in sections when $('#'+id).length > 0

  # Replace Content
  replace: (sections) =>
    $('#'+id).replaceWith(content) for id,content of sections when $('#'+id).length > 0

  # Update Content
  update: (sections) =>
    $('#'+id).html(content) for id,content of sections when $('#'+id).length > 0

  # Set Attribute
  setAttribute: (elements) ->
    $('#'+id).attr(attribute,value) for attribute, value of attributes for id, attributes of elements when $('#'+id).length > 0

  # Reset
  reset: (sections) ->
    $('#'+id)[i].reset() for id, i in sections when $('#'+id).length > 0

  parseResponse: (string) ->
    try
      $.parseJSON string
    catch err
      console.warn 'data returned was not parseable json: '+err if window.console?
      false
