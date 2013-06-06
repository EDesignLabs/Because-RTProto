define ['context-view', 'note-view', 'marker-view'], (ContextView, NoteView, MarkerView)->
    WorkspaceView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher
            @tool = 'move'

            @setElement Visualization.initialize()

            @d3el = d3.select @el

            @d3el.classed @tool, true

            @model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, _.bind @onObjectChanged, @
            @model.get('notes').addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onNotesAdded, @
            @model.get('notes').addEventListener gapi.drive.realtime.EventType.VALUES_REMOVED, _.bind @onNotesRemoved, @
            @model.get('markers').addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onMarkersAdded, @
            @model.get('markers').addEventListener gapi.drive.realtime.EventType.VALUES_REMOVED, _.bind @onMarkersRemoved, @

            @d3el.on 'mousedown', _.bind @onMouseDown, @
            @d3el.on 'mousemove', _.bind @onMouseMove, @
            @d3el.on 'mouseup', _.bind @onMouseUp, @

            @dispatcher.on 'marker:delete', (model)=>
                index = @model.get('markers').indexOf(model)
                @model.get('markers').remove(index) if index?

            @dispatcher.on 'note:delete', (model)=>
                index = @model.get('notes').indexOf(model)
                @model.get('notes').remove(index) if index?

            @dispatcher.on 'tool:set', (tool)=>
                @tool = tool
                @d3el.classed('move', @tool is 'move')
                @d3el.classed('delete', @tool is 'delete')

            data = @model.get 'data'

            @contextView = new ContextView
                model: data.get 'image'
                parent: @d3el
                dispatcher: @dispatcher

            _.each @model.get('markers').asArray(), (marker)-> 
                @addMarker marker
            , @

            _.each @model.get('notes').asArray(), (note)-> 
                @addNote note
            , @

        onMouseDown: (ev) ->
            @dispatcher.trigger 'tool:engage', d3.event, @tool

        onMouseMove: (ev) ->
            @dispatcher.trigger 'tool:move', d3.event, @tool

        onMouseUp: (ev) ->
            @dispatcher.trigger 'tool:release', d3.event, @tool

        onObjectChanged: ->

        onNotesAdded: (rtEvent) ->
            _.each rtEvent.values, (note)->
                @addNote note
            , @

        onNotesRemoved: (rtEvent) ->
            _.each rtEvent.values, (note)->
                @removeObject note
            , @

        onMarkersAdded: (rtEvent) ->
            _.each rtEvent.values, (marker)->
                @addMarker marker
            , @

        onMarkersRemoved: (rtEvent) ->
            _.each rtEvent.values, (marker)->
                @removeObject marker
            , @

        addNote: (note) ->
            noteView = new NoteView
                model: note
                parent: @d3el
                dispatcher: @dispatcher

            noteView.render()

        addMarker: (marker) ->
            markerView = new MarkerView
                model: marker
                parent: @d3el
                dispatcher: @dispatcher

            markerView.render()

        removeObject: (model) ->
            @dispatcher.trigger 'workspace:remove-object', model

        render: ->
            @contextView.render()

