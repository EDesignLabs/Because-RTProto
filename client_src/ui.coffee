define ["realtime-client-utils","marker-view","note-view"], (util, MarkerView, NoteView)->
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
      image: model.createString "http://developers.mozilla.org/files/2917/fxlogo.png"
      spreadsheet: model.createString ""
    context = model.createMap
      notes: notes
      markers: markers
      data: data
      phase: model.createString "1"
      owner: model.createMap()
    model.getRoot().set "context", context

  getObjectFromElement = (d3el, list) ->
    type = d3el.attr 'data-type' if d3el

    if type is 'note-rect' or type is 'marker-circle'
      parentElement = d3.select d3el.node().parentNode
      id = parentElement.attr 'id' if parentElement
      obj = _.filter(list.asArray(), (obj)-> obj.id is id)[0]

    if type is 'handle'
      parentElement = d3.select d3el.node().parentNode
      grandParentElement = d3.select parentElement.node().parentNode
      id = grandParentElement.attr 'id' if grandParentElement
      obj = _.filter(list.asArray(), (obj)-> obj.id is id)[0]

    obj


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
    imageUrl = $("#image-url")
    addMarkerButton = $("#add-marker")
    addNoteButton = $("#add-note")
    addContextButton = $("#add-context")
    displayNoteCreator = $('#display-note-creator')
    displayContextCreator = $('#display-context-creator')
    notesElement = d3.select '#notes'

    activeElement = null
    offsetX = 0
    offsetY = 0

    notesElement.on 'mousedown', ->
      activeElement = d3.select d3.event.target

      if activeElement
        type = activeElement.attr 'data-type'
        obj = getObjectFromElement(activeElement, if type is 'marker-circle' then markers else notes)
        parentElement = d3.select activeElement.node().parentNode

        if obj
          if type is 'note-rect' or type is 'marker-circle'
            matrix = parentElement.attr('transform').slice(7, -1).split(' ')
            x = if matrix[4] isnt 'NaN' then parseInt matrix[4],10 else 0
            y = if matrix[5] isnt 'NaN' then parseInt matrix[5],10 else 0
            offsetX = d3.event.clientX - activeElement.node().offsetLeft - x
            offsetY = d3.event.clientY - activeElement.node().offsetTop - y

          if type is 'handle'
            lineElement = parentElement.select('line')
            lineElement.attr 'opacity', 1.0
            offsetX = d3.event.clientX - activeElement.node().offsetLeft - activeElement.attr('cx')
            offsetY = d3.event.clientY - activeElement.node().offsetTop - activeElement.attr('cy')
        else
          activeElement = null


    notesElement.on 'mousemove', ->
      if activeElement
        type = activeElement.attr 'data-type'
        obj = getObjectFromElement(activeElement, if type is 'marker-circle' then markers else notes)
        parentElement = d3.select activeElement.node().parentNode

        if obj and obj.get('userId')?.getText() is getMe().userId
          if type is 'note-rect' or type is 'marker-circle'
            x = d3.event.clientX - activeElement.node().offsetLeft - offsetX
            y = d3.event.clientY - activeElement.node().offsetTop - offsetY
            parentElement.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"
          if type is 'handle'
            lineElement = parentElement.select('line')
            x = d3.event.clientX - activeElement.node().offsetLeft - offsetX
            y = d3.event.clientY - activeElement.node().offsetTop - offsetY
            activeElement.attr 'cx', x
            activeElement.attr 'cy', y
            lineElement.attr 'x2', x
            lineElement.attr 'y2', y

    notesElement.on 'mouseup', ->
      if activeElement
        type = activeElement.attr 'data-type'
        obj = getObjectFromElement(activeElement, if type is 'marker-circle' then markers else notes)
        parentElement = d3.select activeElement.node().parentNode

        if obj
          if type is 'note-rect'
            matrix = parentElement.attr('transform').slice(7, -1).split(' ')
            model.beginCompoundOperation()
            obj.get('x').setText matrix[4]
            obj.get('y').setText matrix[5]
            #invert selection
            obj.get('selected').setText if obj.get('selected')?.getText() is 'true' then 'false' else 'true'
            model.endCompoundOperation()
          if type is 'marker-circle'
            matrix = parentElement.attr('transform').slice(7, -1).split(' ')
            model.beginCompoundOperation()
            obj.get('x').setText matrix[4]
            obj.get('y').setText matrix[5]
            model.endCompoundOperation()
          if type is 'handle'
            cx = activeElement.attr 'cx'
            cy = activeElement.attr 'cy'
            model.beginCompoundOperation()
            obj.get('hx').setText cx
            obj.get('hy').setText cy
            model.endCompoundOperation()

          offsetX = 0
          offsetY = 0

      activeElement = null

    addNote = (note)->
      noteView = new NoteView
        model: note
        svg: d3.select '#notes'

      noteView.render()

    addMarker = (marker)->
      markerView = new MarkerView
        model: marker
        svg: d3.select '#notes'

      markerView.render()

    $.each notes.asArray(), (index,note)-> addNote note
    $.each markers.asArray(), (index,marker)-> addMarker marker

      # notesElement.select ->
      #   node = noteView.d3el.node()
      #   @appendChild node

    backgroundImageChanged = (rtEvent) ->
      notesElement.select('image').remove()
      contextElement = notesElement.insert "image", ":first-child"
      contextElement.attr 'xlink:href', backgroundImage.getText()
      contextElement.attr 'x', "0"
      contextElement.attr 'y', "0"
      contextElement.attr 'height', "100%"
      contextElement.attr 'width', "100%"

    markersAdded = (rtEvent) ->
      $.each rtEvent.values, (index, marker)->
        addMarker marker

    notesAdded = (rtEvent) ->
      $.each rtEvent.values, (index, note)->
        addNote note

    collaboratorsChanged = (e) ->
      collaboratorsElement = $ "#collaborators"
      collaboratorsElement.empty()

      collaborators = doc.getCollaborators()

      $.each collaborators, (index, collaborator)->
        collaboratorElement = """<span class="collaborator" style="background-color: #{collaborator.color}; background-image: url('#{collaborator.photoUrl}'); background-size: contain; background-repeat: no-repeat; padding-left: 50px">#{collaborator.displayName}</span>"""
        collaboratorsElement.append collaboratorElement

    getMe = () ->
      _.filter(collaborators, (item)-> item.isMe)[0]

    notes.addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, notesAdded
    markers.addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, markersAdded
    backgroundImage.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, backgroundImageChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, collaboratorsChanged
    doc.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, collaboratorsChanged

    displayNoteCreator.click (e)->
      $("#note-creator").toggle()

    displayContextCreator.click (e)->
      $("#context-creator").toggle()

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
      backgroundImage.setText imageUrl.val()
      $("#context-creator").hide()

    backgroundImageChanged()
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