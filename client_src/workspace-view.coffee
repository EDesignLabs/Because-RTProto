define ['context-view', 'note-view', 'marker-view'], (ContextView, NoteView, MarkerView)->
    WorkspaceView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @setElement( $('.workspace-container svg').get(0) )

            @d3el = d3.select @el

            @d3el.attr
                width: '100%'
                height: '100%'

            @context = @model.getModel().getRoot().get 'context'

            @data = @context.get 'data'

            @contextView = new ContextView
                model: @data.get 'image'
                parent: @d3el
                dispatcher: @dispatcher
                insert: ':first-child'

            @context.get('notes').addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onNotesAdded, @
            @context.get('notes').addEventListener gapi.drive.realtime.EventType.VALUES_REMOVED, _.bind @onNotesRemoved, @

            @d3el.on 'mousedown', _.bind @onMouseDown, @
            @d3el.on 'mousemove', _.bind @onMouseMove, @
            @d3el.on 'mouseup', _.bind @onMouseUp, @

            @dispatcher.on 'context:image-load', (url, width, height)=>
                @d3el.attr
                    width: @$el.width()
                    height: @$el.width() / (width/height)

            @dispatcher.on 'note:delete', (model)=>
                index = @context.get('notes').indexOf(model)
                @context.get('notes').remove(index) if index?
                @dispatcher.trigger 'workspace:request-tool',
                    type: 'marker'

            @dispatcher.on 'tool:set', (tool)=>
                @tool = tool
                @d3el.classed('marker', @tool.type is 'marker')
                @d3el.classed('move', @tool.type is 'move')
                @d3el.classed('delete', @tool.type is 'delete')

            @dispatcher.on 'tool:engage', (ev, tool)=>
                if @tool.type is 'marker' and ev.target is @contextView.el
                    @dispatcher.trigger 'marker:add', d3.event, @context

            @dispatcher.on 'context:image-load', (url, width, height)=>
                _.defer _.bind ->
                    viewWidth = $(@d3el.node()).width()
                    viewHeight = $(@d3el.node()).width() / (width/height)

                    @d3el.attr
                        preserveAspectRatio: 'xMinYMin meet'
                        viewBox: "0 0 #{viewWidth} #{viewHeight}"
                , @

            _.each @context.get('notes').asArray(), (note)->
                @addNote note
            , @

        onMouseDown: (ev) ->
            @dispatcher.trigger 'tool:engage', d3.event, @tool

        onMouseMove: (ev) ->
            @dispatcher.trigger 'tool:move', d3.event, @tool

        onMouseUp: (ev) ->
            @dispatcher.trigger 'tool:release', d3.event, @tool

        onNotesAdded: (rtEvent) ->
            _.each rtEvent.values, (note)->
                @addNote note
            , @

        onNotesRemoved: (rtEvent) ->
            _.each rtEvent.values, (note)->
                @removeObject note
            , @

        addNote: (note) ->
            noteView = new NoteView
                doc: @model
                model: note
                parent: @d3el
                dispatcher: @dispatcher

            noteView.render()

        removeObject: (model) ->
            @dispatcher.trigger 'workspace:remove-object', model

        render: ->
            @contextView.render()

