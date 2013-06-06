define ["d3view"], (D3View)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.get('hx').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandleXChanged, this
            @model.get('hy').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandleYChanged, this

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @

        onHandleXChanged: (rtEvent)->
            if @lineElement
                @lineElement.attr
                    'x2': @model.get('hx').getText() || 200

            @circleElement.attr
                'cx': @model.get('hx').getText() || 200

        onHandleYChanged: (rtEvent)->
            if @lineElement
                @lineElement.attr
                    'y2': @model.get('hy').getText() || 25

            @circleElement.attr
                'cy': @model.get('hy').getText() || 25

        onToolEngage: (ev, tool)->
            target = d3.select ev.target

            if target.attr('data-object-id') is @model.id and target.attr('data-type') is 'handle-circle' and @model.get('userId').getText() is tool.user.userId
                if tool.type is 'move'
                    @engaged = true
                    if @lineElement
                        @lineElement.attr 'opacity', 1.0
                    @offsetX = ev.clientX - @circleElement.node().offsetLeft - @circleElement.attr('cx')
                    @offsetY = ev.clientY - @circleElement.node().offsetTop - @circleElement.attr('cy')


        onToolMove: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if tool.type is 'move'
                    x = ev.clientX - @circleElement.node().offsetLeft - @offsetX
                    y = ev.clientY - @circleElement.node().offsetTop - @offsetY
                    @circleElement.attr 'cx', x
                    @circleElement.attr 'cy', y
                    @lineElement.attr 'x2', x if @lineElement
                    @lineElement.attr 'y2', y if @lineElement

        onToolRelease: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if tool.type is 'move'
                    cx = @circleElement.attr 'cx'
                    cy = @circleElement.attr 'cy'
                    @model.get('hx').setText cx
                    @model.get('hy').setText cy

                    @engaged = false

        render: ->
            @d3el.attr
                'id': 'handle-' + @model.id
                'data-type': 'handle'
                'data-object-id': @model.id

            if @model.get('title').getText()

                @lineElement = @d3el.append 'line' if not @lineElement
                @lineElement.attr
                    'id': 'handle-line-' + @model.id
                    'x1': 100
                    'y1': 25
                    'x2': @model.get('hx').getText() || 200
                    'y2': @model.get('hy').getText() || 25
                    'stroke': 'black'
                    'strokeWidth': 2
                    'opacity': if @model.get('selected').getText() is 'true' then 0.0 else 1.0
                    'data-type': 'handle-line'
                    'data-object-id': @model.id

            @circleElement = @d3el.append 'circle' if not @circleElement
            @circleElement.attr
                'id': 'handle-circle-' + @model.id
                'r': 5
                'cx': @model.get('hx').getText() || 200
                'cy': @model.get('hy').getText() || 25
                'fill': @model.get('color')?.getText() or 'gray'
                'stroke': if @model.get('selected').getText() is 'true' then 'black' else 'darkslateblue'
                'strokeWidth': 10
                'data-type': 'handle-circle'
                'data-object-id': @model.id
