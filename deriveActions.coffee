###
# @author Travis Jeppson <travis@plaidtie.net>
# @depends jQuery
###
class DeriveActions
  deriveActions: (data) ->
    data = @parseResponse data if typeof data == 'string'
    (@[action]?(attrs) for action,attrs of data.actions when data.actions?) unless typeof data == 'string' # exit if parseResponse is not an object

    # clean data.content if it exists
    if _.isString(data.content)
      data.content = JSMonitor.clean(data.content)
    else if _.isObject(data.content)
      data.content[i] = JSMonitor.clean(data.content[i]) for i in json.content

    return data

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
    $('#'+id).trigger('reload') for id in sections when $('#'+id).length > 0

  # Replace Content
  replace: (sections) =>
    $('#'+id).replaceWith(JSMonitor.clean(content)) for id,content of sections when $('#'+id).length > 0

  # Update Content
  update: (sections) =>
    $('#'+id).html(JSMonitor.clean(content)) for id,content of sections when $('#'+id).length > 0

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

JSMonitor = {}
JSMonitor.loaded = []
JSMonitor.clean = (content) ->
    # console.log content
    scriptTags = content.match /<script.+?>[\s\S]*?<\/script>/gm
    if scriptTags isnt null
      for tag in scriptTags
        scriptSrc = tag.match /src=(?:"|').+\/(.+?)(?:"|')/
        if scriptSrc isnt null and @loaded.indexOf(scriptSrc[1]) is -1 # doesn't exist, add to loaded
          console.log '------------ ALLOWING: '+scriptSrc[1]
          @loaded.push(scriptSrc[1])
          continue
        else if scriptSrc isnt null # already exists don't load
          # console.warn '------------ BLOCKING: '+scriptSrc[1]
          content = content.replace(scriptSrc['input'],'') # remove from content
          continue

        # check document delegations
        delegateExp = /^(?:jQuery|$)\([^\)]+\).on\(/m
        jQueryExp = /^(?:jQuery|$)/m
        start2 = 0
        start = tag.search(delegateExp)
        failsafe = 20
        while failsafe -= 1
          start2 = tag.substr(start+1).search(jQueryExp)
          start2 = if start2 <= 0 then tag.substr(start).length else start2
          delegateSlice = tag.substr(start,start2)
          # check if delegateSlice really contains a delegate
          containsDelegate = delegateSlice.match(/(?:jQuery|\$)\(document\)\.on\(('|")([^\1]+?)\1\s*,\s*('|")([^\3]+?)(?:\3)/)
          if containsDelegate and @loaded.indexOf(containsDelegate[4]) is -1 # doesn't exist, add to loaded
            console.log '------------ ALLOWING: '+containsDelegate[4]
            @loaded.push containsDelegate[4]
          else if containsDelegate isnt null
            # console.warn '------------ BLOCKING: '+containsDelegate[4]
            content = content.replace(containsDelegate['input'],''); # remove from content

          start = if start2 <= 0 then -1 else start2+start+1
          start = tag.substr(start).search(delegateExp)+start
          break if 0 < start < tag.length

    return content
