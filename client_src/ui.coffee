define ["realtime-client-utils"], (util)->
  ###
  This function is called the first time that the Realtime model is created
  for a file. This function should be used to initialize any values of the
  model. In this case, we just create the single string model that will be
  used to control our text box. The string has a starting value of 'Hello
  Realtime World!', and is named 'text'.
  @param model {gapi.drive.realtime.Model} the Realtime root model object.
  ###
  initializeModel = (model) ->
    notes = model.createList()
    context = model.createMap
      notes: notes
      background: "http://developers.mozilla.org/files/2917/fxlogo.png"
    model.getRoot().set "context", context


  ###
  This function is called when the Realtime file has been loaded. It should
  be used to initialize any user interface components and event handlers
  depending on the Realtime model. In this case, create a text control binder
  and bind it to our string model that we created in initializeModel.
  @param doc {gapi.drive.realtime.Document} the Realtime document.
  ###
  onFileLoaded = (doc) ->
    model = doc.getModel();
    notes = model.getRoot().get("context").get "notes"
    context = model.getRoot().get("context")

    # Keeping one box updated with a String binder.
    title = $("#title")
    desc = $("#desc")
    url = $("#url")
    image_url = $("#image-url")
    addNoteButton = $("#add-note")
    addContextButton = $("#add-context")
    displayNoteCreator = $('#display-note-creator')
    displayContextCreator = $('#display-context-creator')
    activeElement = null
    offsetX = 0
    offsetY = 0

    backgroundChanged = (rtEvent) ->
      notesElement = d3.select '#notes'

      contextElement = notesElement.insert "image", ":first-child"
      contextElement.attr 'xlink:href', context.get 'background'
      contextElement.attr 'x', "0"
      contextElement.attr 'y', "0"
      contextElement.attr 'height', "100%"
      contextElement.attr 'width', "100%"

    notesChanged = (rtEvent) ->
      notesElement = d3.select '#notes'
      notesElement.selectAll('*').each (d,i)->
        d3.select(this).remove()

      notesElement.on 'mousedown', ->
        activeElement = d3.select d3.event.target
        type = activeElement.attr 'data-type' if activeElement
        note = notes.get parseInt activeElement.attr('data-index'),10 if activeElement and activeElement.attr 'data-index'

        if note
          if type is 'note-rect'
            parentElement = d3.select activeElement.node().parentNode
            matrix = parentElement.attr('transform').slice(7, -1).split(' ')
            x = if matrix[4] isnt 'NaN' then parseInt matrix[4],10 else 0
            y = if matrix[5] isnt 'NaN' then parseInt matrix[5],10 else 0
            offsetX = d3.event.clientX - activeElement.node().offsetLeft - x
            offsetY = d3.event.clientY - activeElement.node().offsetTop - y

          if type is 'handle'
            parentElement = d3.select activeElement.node().parentNode
            grandParentElement = d3.select parentElement.node().parentNode
            lineElement = parentElement.select('line')
            lineElement.attr 'opacity', 1.0
            offsetX = d3.event.clientX - activeElement.node().offsetLeft - activeElement.attr('cx')
            offsetY = d3.event.clientY - activeElement.node().offsetTop - activeElement.attr('cy')


      notesElement.on 'mousemove', ->
        type = activeElement.attr 'data-type' if activeElement
        note = notes.get parseInt activeElement.attr('data-index'),10 if activeElement and activeElement.attr 'data-index'

        if note
          # if type is 'note-rect'
          #   parentElement = d3.select activeElement.node().parentNode
          #   x = d3.event.clientX - activeElement.node().offsetLeft - offsetX
          #   y = d3.event.clientY - activeElement.node().offsetTop - offsetY
          #   parentElement.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"
          if type is 'handle'
            parentElement = d3.select activeElement.node().parentNode
            lineElement = parentElement.select('line')
            x = d3.event.clientX - activeElement.node().offsetLeft - offsetX
            y = d3.event.clientY - activeElement.node().offsetTop - offsetY
            activeElement.attr 'cx', x
            activeElement.attr 'cy', y
            lineElement.attr 'x2', x
            lineElement.attr 'y2', y

      notesElement.on 'mouseup', ->
        type = activeElement.attr 'data-type' if activeElement
        note = notes.get parseInt activeElement.attr('data-index'),10  if activeElement and activeElement.attr 'data-index'

        if note
          if type is 'note-rect'
            parentElement = d3.select activeElement.node().parentNode
            matrix = parentElement.attr('transform').slice(7, -1).split(' ')
            note.set 'x', matrix[4]
            note.set 'y', matrix[5]
            #invert selection
            lineElement = parentElement.select('line')
            lineElement.attr 'opacity', if note.get 'selected' then 0.0 else 1.0
            note.set 'selected', (not note.get 'selected')
          if type is 'handle'
            parentElement = d3.select activeElement.node().parentNode
            grandParentElement = d3.select parentElement.node().parentNode
            lineElement = parentElement.select('line')
            lineElement.attr 'opacity', if note.get 'selected' then 1.0 else 0.0
            note.set 'hx', activeElement.attr 'cx'
            note.set 'hy', activeElement.attr 'cy'

          offsetX = 0
          offsetY = 0

        activeElement = null

      $.each notes.asArray(), (index, note)->
        noteElement = notesElement.append 'g'
        noteElement.attr 'id', note.id
        noteElement.attr 'x', 0
        noteElement.attr 'y', 0
        noteElement.attr 'data-type', 'note'
        noteElement.attr 'data-index', index
        noteElement.attr 'fill', '#fff'
        noteElement.attr 'stroke', 'black'
        noteElement.attr 'transform', "matrix(1 0 0 1 #{note.get('x')} #{note.get('y')})"

        noteRectElement = noteElement.append('rect').attr('width', 100).attr('height', 50)
        noteRectElement.attr 'data-type', 'note-rect'
        noteRectElement.attr 'data-index', index

        titleElement = noteElement.append('text').text note.get 'title'
        titleElement.attr 'style','fill:black;stroke:none'
        titleElement.attr 'x', 5
        titleElement.attr 'y', 15
        titleElement.attr 'font-size', 12
        descElement = noteElement.append('text').text note.get 'desc'
        descElement.attr('style','fill:blue;stroke:none')
        descElement.attr 'x', 5
        descElement.attr 'y', 30
        descElement.attr 'width', 50
        descElement.attr 'height', 'auto'
        descElement.attr 'font-size', 8

        lineGroupElement = noteElement.append 'g'

        lineElement = lineGroupElement.append('line').attr('x1', 100).attr('y1', 50).attr('x2', note.get('hx') || 200).attr('y2', note.get('hy') || 50)
        lineElement.attr 'stroke', 'black'
        lineElement.attr 'strokeWidth', 2
        lineElement.attr 'opacity', if note.get 'selected' then 0.0 else 1.0

        handleElement = lineGroupElement.append('circle').attr('r', 5).attr('cx', note.get('hx') || 200).attr('cy', note.get('hy') || 50)
        handleElement.attr 'stroke', 'black'
        handleElement.attr 'strokeWidth', 10
        handleElement.attr 'data-type', 'handle'
        handleElement.attr 'data-index', index

        noteItemElement = $ """<li id="note-item-#{note.id}" class="note-item">
          <h2><a href="#{note.get('url')}">#{note.get('title')}</a></h2>
          <p>#{note.get('desc')}</p></li>"""

        noteItemElement.click (e)->
          noteElement.transition().duration(100).attr('fill', '#ff0')
          noteElement.transition().delay(500).duration(500).attr('fill', '#fff')

        if rtEvent?.target?.id is note.id
          collaborators = _.filter doc.getCollaborators(), (item)->
            item.userId is rtEvent.userId and not item.isMe
          if collaborators.length > 0
            author = collaborators[0]?.displayName
            authorColor = collaborators[0]?.color
            authorElement = $ """<span class="collaborator" style="display: none; background-color: #{authorColor}; color: white;">#{author}</span>"""
            noteElement.append authorElement
            authorElement.fadeIn()
            _.delay (-> authorElement.fadeOut()), 2000

    collaboratorsChanged = (e) ->
      collaboratorsElement = $ "#collaborators"
      collaboratorsElement.empty()

      collaborators = doc.getCollaborators()

      $.each collaborators, (index, collaborator)->
        collaboratorElement = """<span class="collaborator" style="background-color: #{collaborator.color}">#{collaborator.displayName}</span>"""
        collaboratorsElement.append collaboratorElement


    notes.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, notesChanged
    context.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, backgroundChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

    displayNoteCreator.click (e)->
      $("#note-creator").show()

    displayContextCreator.click (e)->
      $("#context-creator").show()

    addNoteButton.click (e)->
      if notes.length > 0
        lastY = parseInt(notes.get(notes.length-1).get 'y') + 50
      else
        lastY = 0
      newNote = doc.getModel().createMap
        title: title.val()
        desc: desc.val()
        url: url.val()
        x: 0
        y: lastY
        selected: false
      notes.push newNote
      e.preventDefault()
      $("#note-creator").hide()
      false

    addContextButton.click (e)->
      context.set 'background', image_url.val()
      $("#context-creator").hide()

    backgroundChanged()
    notesChanged()
    collaboratorsChanged()

  realtimeOptions =

    ###
    Options for the Realtime loader.
    ###

    ###
    Client ID from the APIs Console.
    ###
    clientId: window.GOOGLE_API_CLIENT_ID

    ###
    The ID of the button to click to authorize. Must be a DOM element ID.
    ###
    authButtonElementId: "authorizeButton"

    ###
    Function to be called when a Realtime model is first created.
    ###
    initializeModel: initializeModel

    ###
    Autocreate files right after auth automatically.
    ###
    autoCreate: true

    ###
    Autocreate files right after auth automatically.
    ###
    defaultTitle: "Because Realtime File"

    ###
    Function to be called every time a Realtime file is loaded.
    ###
    onFileLoaded: onFileLoaded

  return {
    rtclient: new util.RTClient(window)

    ###
    Start the Realtime loader with the options.
    ###
    startRealtime: (rtclient) ->
      realtimeLoader = rtclient.getRealtimeLoader(realtimeOptions)
      realtimeLoader.start()
  }