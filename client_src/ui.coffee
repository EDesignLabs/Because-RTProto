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
      notesElement = $ '#notes'
      notesElement.empty()

      notesListElement = $ '#notes-list'
      notesListElement.empty()

      $.each notes.asArray(), (index, note)->
        noteElement = $ """<div id="note-#{note.id}" class="note"><h2>#{note.get('title')}</h2></div>"""
        
        noteItemElement = $ """<div id="note-item-#{note.id}" class="note-item">
          <h2><a href="#{note.get('url')}">#{note.get('title')}</a></h2>
          <p>#{note.get('desc')}</p></div>"""
        
        noteElement.draggable
          stop: ->
            x = $(@).offset().left
            y = $(@).offset().top
            model.beginCompoundOperation()
            note.set 'x', x
            note.set 'y', y
            model.endCompoundOperation()

        noteItemElement.click (e)->
          $("#note-#{note.id}").animate(
            backgroundColor: '#ff0'            
          , 200).animate(
            backgroundColor: '#fff'            
          , 200)

        
        notesElement.append noteElement
        notesListElement.append noteItemElement

        noteElement.offset
          left: note.get('x') || 0
          top: note.get('y') || 0

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