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
      model: doc
      el: $('.control')
      dispatcher: dispatcher

    workspaceView.render()
    controlView.render()

    $('.workspace-container').append workspaceView.$el

    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

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