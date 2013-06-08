define ["d3view"], (D3View)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.get('hx').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandleXChanged, @
            @model.get('hy').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandleYChanged, @
            @model.get('color').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onColorChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onDescriptionChanged, @

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @
            @dispatcher.on 'collaborator:selected', _.bind @onCollaboratorSelected, @

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

        onColorChanged: (rtEvent)->
            @circleElement.attr
                'fill': @model.get('color').getText() || 'gray'

        onTitleChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderLine()
            else
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                    @renderLine()
                else
                    @lineElement.remove() if @lineElement
                    delete @lineElement if @lineElement

        onDescriptionChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") is ''
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                    @renderLine()
                else
                    @lineElement.remove() if @lineElement
                    delete @lineElement if @lineElement

        onToolEngage: (ev, tool)->
            target = d3.select ev.target

            target = d3.select ev.target

            if target.attr('data-object-id') is @model.id and target.attr('data-type') is 'handle-circle'

                @dispatcher.trigger 'note:view', d3.event, @model if tool.type is 'view'

                if @model.get('userId').getText() isnt '' and @model.get('userId').getText() isnt tool.user.userId and not tool.user.isOwner()
                    @dispatcher.trigger 'note:view', d3.event, @model if tool.type is 'note'

                else
                    #user-restricted actions are below here

                    @dispatcher.trigger 'note:delete', @model if tool.type is 'delete'

                    @dispatcher.trigger 'note:edit', d3.event, @model if tool.type is 'note'

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
                if @model.get('userId').getText() is '' and not tool.user.isOwner()
                    @model.get('userId').setText tool.user.userId
                    @model.get('color').setText tool.user.color

                if tool.user.isOwner()
                    @model.get('userId').setText ''
                    @model.get('color').setText 'gray'

                if tool.type is 'move'
                    cx = @circleElement.attr 'cx'
                    cy = @circleElement.attr 'cy'
                    @model.get('hx').setText cx
                    @model.get('hy').setText cy

                    @engaged = false

        onCollaboratorSelected: (collaborator)->
            if collaborator.userId is @model.get('userId').getText() and @circleElement?
                @circleElement.transition().attr('fill','white').attr('r',6).duration(200)
                @circleElement.transition().attr('fill',@model.get('color')?.getText() or 'gray').attr('r',5).delay(1000).duration(200)

        render: ->
            @d3el.attr
                'id': 'handle-' + @model.id
                'data-type': 'handle'
                'data-object-id': @model.id

            if @model.get('title').getText() or @model.get('desc').getText()
                @renderLine()

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

        renderLine: ->
            @lineElement = @d3el.insert 'line', ':first-child' if not @lineElement
            @lineElement.attr
                'id': 'handle-line-' + @model.id
                'x1': 75
                'y1': 12
                'x2': @model.get('hx').getText() || 200
                'y2': @model.get('hy').getText() || 25
                'stroke': 'black'
                'strokeWidth': 2
                'opacity': if @model.get('selected').getText() is 'true' then 0.0 else 1.0
                'data-type': 'handle-line'
                'data-object-id': @model.id
