define ['context-view', 'note-view', 'marker-view'], (ContextView, NoteView, MarkerView)->
    WorkspaceView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            @constructor.__super__.initialize.call @, options

            @setElement document.createElementNS('http://www.w3.org/2000/svg','svg')

            @d3el = d3.select @el

            @model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, _.bind @onObjectChanged, @
            @model.get('notes').addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onNotesAdded, @
            @model.get('markers').addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onMarkersAdded, @

            data = @model.get 'data'

            @contextView = new ContextView
                model: data.get 'image'
                parent: @d3el

            _.each @model.get('markers').asArray(), (marker)-> 
                @addMarker marker
            , @

            _.each @model.get('notes').asArray(), (note)-> 
                @addNote note
            , @

        onObjectChanged: ->

        onNotesAdded: (rtEvent) ->
            _.each rtEvent.values, (note)->
                @addNote note
            , @

        onMarkersAdded: (rtEvent) ->
            _.each rtEvent.values, (marker)->
                @addMarker marker
            , @


        addNote: (note) ->
            noteView = new NoteView
                model: note
                parent: @d3el

            noteView.render()

        addMarker: (marker) ->
            markerView = new MarkerView
                model: marker
                parent: @d3el

            markerView.render()

        render: ->
            @contextView.render()

