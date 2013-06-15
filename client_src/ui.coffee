define ["realtime-client-utils", "collaborators-view", "workspace-view", "control-view"], (util, CollaboratorsView, WorkspaceView, ControlView)->
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
    data = model.createMap
      title: model.createString "Title or question"
      desc: model.createString "Instuctions or description"
      image: model.createString "/images/splash.png"
      spreadsheet: model.createString "https://docs.google.com/spreadsheet/pub?key=0Ar2Io2uAtw9TdEFvb2t5U3BiZDhQRlNSRjRTY3Q2Rmc&output=html"
    context = model.createMap
      notes: notes
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

    dispatcher = _.clone Backbone.Events

    collaboratorsView = new CollaboratorsView
      model: doc
      el: $('#collaborators')
      dispatcher: dispatcher

    workspaceView = new WorkspaceView
      model: doc
      dispatcher: dispatcher

    controlView = new ControlView
      model: doc
      el: $('.control')
      dispatcher: dispatcher

    collaboratorsView.render()
    workspaceView.render()
    controlView.render()

    $('.workspace-container').append workspaceView.$el

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