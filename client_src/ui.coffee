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

    notesChanged = (e) ->
      notesElement = d3.select '#notes'
      notesElement.selectAll('*').each (d,i)->
        d3.select(this).remove()

      notesListElement = $ '#notes-list'
      notesListElement.empty()

      $.each notes.asArray(), (index, note)->
        noteElement = notesElement.append 'g'
        noteElement.append('rect').attr('width', 100).attr('height', 100)
        noteElement.append('text').attr('style','fill:red;stroke:none').text note.get 'title'
        noteElement.attr 'id', note.id
        noteElement.attr 'x', 0
        noteElement.attr 'y', 0
        noteElement.attr 'fill', '#fff'
        noteElement.attr 'stroke', 'black'
        noteElement.attr 'transform', "matrix(1 0 0 1 #{note.get('x')} #{note.get('y')})"
        
        noteElement.on 'mousedown', (d,i)->
          matrix = noteElement.attr('transform').slice(7, -1).split(' ')
          offsetX = d3.event.clientX - notesElement[0][0].offsetLeft - matrix[4]
          offsetY = d3.event.clientY - notesElement[0][0].offsetTop - matrix[5]
          noteElement.on 'mousemove', (d,i)->
            console.log d3.event
            x = d3.event.clientX - notesElement[0][0].offsetLeft - offsetX
            y = d3.event.clientY - notesElement[0][0].offsetTop - offsetY
            noteElement.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"


        noteElement.on 'mouseup', (d,i)->
          noteElement.on 'mousemove', null
          matrix = noteElement.attr('transform').slice(7, -1).split(' ')
          console.log 'start'
          model.beginCompoundOperation()
          note.set 'x', matrix[4]
          note.set 'y', matrix[5]
          model.endCompoundOperation()
          console.log 'end'
        
        noteElement.on 'mouseout', (d,i)->
          noteElement.on 'mousemove', null
        
        noteItemElement = $ """<li id="note-item-#{note.id}" class="note-item">
          <h2><a href="#{note.get('url')}">#{note.get('title')}</a></h2>
          <p>#{note.get('desc')}</p></li>"""

        # noteElement.draggable
        #   stop: ->
        #     x = $(@).offset().left
        #     y = $(@).offset().top
        #     model.beginCompoundOperation()
        #     note.set 'x', x
        #     note.set 'y', y
        #     model.endCompoundOperation()

        noteItemElement.click (e)->
          noteElement.transition().duration(100).attr('fill', '#ff0')
          noteElement.transition().delay(500).duration(500).attr('fill', '#fff')


        # notesElement.append noteElement
        notesListElement.append noteItemElement

        # noteElement.offset
        #   left: note.get('x') || 0
        #   top: note.get('y') || 0

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

      collaborators = _.uniq doc.getCollaborators(), true, (item)-> item.id

      $.each collaborators, (index, collaborator)->
        collaboratorElement = """<span class="collaborator" style="background-color: #{collaborator.color}">#{collaborator.displayName}</span>"""
        collaboratorsElement.append collaboratorElement


    notes.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, notesChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

    addNoteButton.click ->
      newNote = doc.getModel().createMap
        title: title.val()
        desc: desc.val()
        url: url.val()
      notes.push newNote
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