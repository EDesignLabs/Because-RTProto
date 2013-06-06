define ["realtime-client-utils", "workspace-view", "control-view"], (util, WorkspaceView, ControlView)->
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
    markers = model.createList()
    data = model.createMap
      title: model.createString "Title or question"
      desc: model.createString "Instuctions or description"
      image: model.createString "http://developers.mozilla.org/files/2917/fxlogo.png"
      spreadsheet: model.createString ""
    context = model.createMap
      notes: notes
      markers: markers
      data: data
      phase: model.createString "1"
      owner: model.createMap
        userId: model.createString()
        color: model.createString()
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
    root = model.getRoot()
    context = root.get 'context'
    notes = context.get 'notes'
    markers = context.get 'markers'
    data = context.get 'data'
    backgroundImage = data.get 'image'
    collaborators = doc.getCollaborators()

    # Keeping one box updated with a String binder.
    title = $("#title")
    desc = $("#desc")
    url = $("#url")
    moveTool = $("#move-tool")
    deleteTool = $("#delete-tool")
    addMarkerButton = $("#add-marker")
    addNoteButton = $("#add-note")
    addContextButton = $("#add-context")
    displayNoteCreator = $('#display-note-creator')
    displayContextCreator = $('#display-context-creator')
    closeModalButton = $('.hide-modal')
    notesElement = d3.select '#notes'

    dispatcher = _.clone Backbone.Events

    collaboratorsChanged = (e) ->
      collaboratorsElement = $ "#collaborators"
      collaboratorsElement.empty()

      collaborators = doc.getCollaborators()

      $.each collaborators, (index, collaborator)->
        collaboratorElement = """<span class="collaborator" style="background-color: #{collaborator.color};">#{collaborator.displayName}</span>"""
        collaboratorsElement.append collaboratorElement

    getMe = () ->
      _.filter(collaborators, (item)-> item.isMe)[0]

    workspaceView = new WorkspaceView
      model: context
      dispatcher: dispatcher

    controlView = new ControlView
      model: context
      el: $('.control')
      dispatcher: dispatcher

    workspaceView.render()
    controlView.render()

    dispatcher.trigger 'tool:set',
        type: 'move'
        user: getMe()

    $('.workspace-container').append workspaceView.$el

    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

    moveTool.click (e)->
      workspaceView.dispatcher.trigger 'tool:set',
        type: 'move'
        user: getMe()

    deleteTool.click (e)->
      workspaceView.dispatcher.trigger 'tool:set',
        type: 'delete'
        user: getMe()

    displayNoteCreator.click (e)->
      $("#note-creator").toggle()

    displayContextCreator.click (e)->
      $("#context-creator").toggle()

    closeModalButton.click (e) ->
      $(this).parent().hide()

    addNoteButton.click (e)->
      $("#context-creator").hide()
      if notes.length > 0
        if notes.get(notes.length-1).get('y') and notes.get(notes.length-1).get('x') is '0'
          lastY = parseInt(notes.get(notes.length-1).get('y')?.getText() or '0') + 50
        else
          lastY = 0
      else
        lastY = 0
      newNote = doc.getModel().createMap
        title: doc.getModel().createString title.val()
        desc: doc.getModel().createString desc.val()
        url: doc.getModel().createString url.val()
        x: doc.getModel().createString '0'
        y: doc.getModel().createString if lastY isnt NaN and lastY isnt 'NaN' then lastY+'' else 0
        hx: doc.getModel().createString '200'
        hy: doc.getModel().createString '25'
        selected: doc.getModel().createString 'false'
        userId: doc.getModel().createString getMe().userId
        color: doc.getModel().createString getMe().color
      notes.push newNote
      e.preventDefault()
      $("#note-creator").hide()
      title.val('')
      desc.val('')
      url.val('')
      false

    addMarkerButton.click (e)->
      $("#note-creator").hide()
      $("#context-creator").hide()
      if markers.length > 0
        if markers.get(markers.length-1).get('y')? and markers.get(markers.length-1).get('x')?.getText() is '400'
          lastY = parseInt(markers.get(markers.length-1).get('y').getText() or '0') + 10
        else
          lastY = 0
      else
        lastY = 0
      newMarker = doc.getModel().createMap
        x: doc.getModel().createString '400'
        y: doc.getModel().createString lastY+''
        userId: doc.getModel().createString getMe().userId
        color: doc.getModel().createString getMe().color
      markers.push newMarker
      e.preventDefault()
      false

    addContextButton.click (e)->
      $("#note-creator").hide()
      imageUrl = $("#image-url")
      documentTitle = $("#document-title")
      documentDesc = $("#document-desc")

      backgroundImage.setText imageUrl.val()
      data.get('title').setText documentTitle.val()
      data.get('desc').setText documentDesc.val()
      data.get('owner').get('userId').setText getMe().userId
      data.get('owner').get('color').setText getMe().color
      $("#context-creator").hide()

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