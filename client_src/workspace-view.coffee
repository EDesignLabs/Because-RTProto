define ['context-view', 'note-view', 'marker-view'], (ContextView, NoteView, MarkerView)->
    WorkspaceView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @setElement document.createElementNS('http://www.w3.org/2000/svg','svg')

            @d3el = d3.select @el

            @d3el.attr
                width: '100%'
                height: '100%'

            @data = @model.get 'data'

            @contextView = new ContextView
                model: @data.get 'image'
                parent: @d3el
                dispatcher: @dispatcher

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
                @d3el.classed('view', @tool.type is 'view')
                @d3el.classed('marker', @tool.type is 'marker')
                @d3el.classed('note', @tool.type is 'note')
                @d3el.classed('move', @tool.type is 'move')
                @d3el.classed('delete', @tool.type is 'delete')

            @dispatcher.on 'tool:engage', (ev, tool)=>
                if @tool.type is 'note' and ev.target is @contextView.el
                    @dispatcher.trigger 'note:add', d3.event, @model
                if @tool.type is 'marker' and ev.target is @contextView.el
                    @dispatcher.trigger 'marker:add', d3.event, @model

            @dispatcher.on 'context:image-load', (url, width, height)=>
                _.defer _.bind ->
                    width = $(@d3el.node()).width()
                    height = $(@d3el.node()).height()

                    @d3el.attr
                        preserveAspectRatio: 'xMinYMin meet'
                        viewBox: "0 0 #{width} #{height}"
                , @

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

