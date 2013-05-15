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
    note = model.createMap
      title: "The Title 2"
      desc: "The Description 2"
      url: "http://google.com"
      x: 0
      y: 0
      hx: 0
      hy: 0
      positioned: true
    notes = model.createList()
    model.getRoot().set "notes", notes
    notes.push note


  ###
  This function is called when the Realtime file has been loaded. It should
  be used to initialize any user interface components and event handlers
  depending on the Realtime model. In this case, create a text control binder
  and bind it to our string model that we created in initializeModel.
  @param doc {gapi.drive.realtime.Document} the Realtime document.
  ###
  onFileLoaded = (doc) ->
    model = doc.getModel();
    notes = model.getRoot().get("notes")

    # Keeping one box updated with a String binder.
    title = $("#title")
    desc = $("#desc")
    url = $("#url")
    addNoteButton = $("#add-note")
    activeElement = null
    offsetX = 0
    offsetY = 0

    notesChanged = (e) ->
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
            offsetX = d3.event.clientX - activeElement.node().offsetLeft - activeElement.attr('cx')
            offsetY = d3.event.clientY - activeElement.node().offsetTop - activeElement.attr('cy')


      notesElement.on 'mousemove', ->
        type = activeElement.attr 'data-type' if activeElement
        note = notes.get parseInt activeElement.attr('data-index'),10 if activeElement and activeElement.attr 'data-index'

        if note
          if type is 'note-rect'
            parentElement = d3.select activeElement.node().parentNode
            x = d3.event.clientX - activeElement.node().offsetLeft - offsetX
            y = d3.event.clientY - activeElement.node().offsetTop - offsetY
            parentElement.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"
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
          if type is 'handle'
            note.set 'hx', activeElement.attr 'cx'
            note.set 'hy', activeElement.attr 'cy'

          offsetX = 0
          offsetY = 0

        activeElement = null

      notesListElement = $ '#notes-list'
      notesListElement.empty()

      $.each notes.asArray(), (index, note)->
        noteElement = notesElement.append 'g'
        noteElement.append('text').attr('style','fill:red;stroke:none').text note.get 'title'
        noteElement.attr 'id', note.id
        noteElement.attr 'x', 0
        noteElement.attr 'y', 0
        noteElement.attr 'data-type', 'note'
        noteElement.attr 'data-index', index
        noteElement.attr 'fill', '#fff'
        noteElement.attr 'stroke', 'black'
        noteElement.attr 'transform', "matrix(1 0 0 1 #{note.get('x')} #{note.get('y')})"

        noteRectElement = noteElement.append('rect').attr('width', 100).attr('height', 100)
        noteRectElement.attr 'data-type', 'note-rect'
        noteRectElement.attr 'data-index', index

        lineGroupElement = noteElement.append 'g'

        lineElement = lineGroupElement.append('line').attr('x1', 100).attr('y1', 50).attr('x2', note.get('hx') || 200).attr('y2', note.get('hy') || 50)
        lineElement.attr 'stroke', 'black'
        lineElement.attr 'strokeWidth', 2

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

        notesListElement.append noteItemElement

        if e and note.id is e.target.id
          collaborators = _.filter doc.getCollaborators(), (item)->
            item.userId is e.userId and not item.isMe
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
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

    addNoteButton.click (e)->
      newNote = doc.getModel().createMap
        title: title.val()
        desc: desc.val()
        url: url.val()
      notes.push newNote
      e.preventDefault()
      false

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
    defaultTitle: "New Realtime Quickstart File"

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