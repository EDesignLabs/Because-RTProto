define ['d3view', 'handle-view'], (D3View, HandleView)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.get('x').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, @
            @model.get('y').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onDescriptionChanged, @

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @

        onHandlePositionChanged: (rtEvent)->
            @d3el.attr
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

        onTitleChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderTitle(@model.get('title').getText())
            else
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") is ''
                    @noteRectElement.remove() if @noteRectElement
                    @titleElement.remove() if @titleElement
                    delete @noteRectElement if @noteRectElement
                    delete @titleElement if @titleElement
                else
                    abridged = @model.get('desc').getText().substr(0,15) + '...'
                    @renderTitle(abridged)

        onDescriptionChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") is ''
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                    abridged = @model.get('desc').getText().substr(0,15) + '...'
                    @renderTitle(abridged)
                else
                    @noteRectElement.remove() if @noteRectElement
                    @titleElement.remove() if @titleElement
                    delete @noteRectElement if @noteRectElement
                    delete @titleElement if @titleElement

        onToolEngage: (ev, tool)->
            target = d3.select ev.target

            if target.attr('data-object-id') is @model.id and (target.attr('data-type') is 'note-rect' or target.attr('data-type') is 'title')

                @dispatcher.trigger 'note:view', d3.event, @model if tool.type is 'view'

                if @model.get('userId').getText() isnt tool.user.userId
                    @dispatcher.trigger 'note:view', d3.event, @model if tool.type is 'note'

                else
                    #user-restricted actions are below here

                    @dispatcher.trigger 'note:delete', @model if tool.type is 'delete'

                    @dispatcher.trigger 'note:edit', d3.event, @model if tool.type is 'note'

                    if tool.type is 'move'
                        @engaged = true
                        matrix = @d3el.attr('transform').slice(7, -1).split(' ')
                        x = if matrix[4] isnt 'NaN' then parseInt matrix[4],10 else 0
                        y = if matrix[5] isnt 'NaN' then parseInt matrix[5],10 else 0
                        @offsetX = ev.clientX - @el.offsetLeft - x
                        @offsetY = ev.clientY - @el.offsetTop - y


        onToolMove: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if tool.type is 'move'
                    x = ev.clientX - @el.offsetLeft - @offsetX
                    y = ev.clientY - @el.offsetTop - @offsetY
                    @d3el.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"
            else
                if target.attr('data-object-id') is @model.id
                    @noteRectElement?.attr
                        'stroke': 'red'
                else
                    @noteRectElement?.attr
                        'stroke': 'black'


        onToolRelease: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if tool.type is 'move'
                    matrix = @d3el.attr('transform').slice(7, -1).split(' ')
                    @model.get('x').setText matrix[4]
                    @model.get('y').setText matrix[5]

                    @engaged = false


        render: ->
            @d3el.attr
                'id': 'note-' + @model.id
                'x': 0
                'y': 0
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"
                'data-type': 'note'
                'data-object-id': @model.id

            abridged = @model.get('desc').getText().substr(0,18) + '...'

            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderTitle(@model.get('title').getText())
            else if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderTitle(abridged)

            if not @handleView
                @handleView = new HandleView
                    model: @model
                    parent: @d3el
                    dispatcher: @dispatcher

                @handleView.render()

        renderTitle: (title)->
            unless @noteRectElement
                @noteRectElement = @d3el.append 'rect' if not @noteRectElement
                @noteRectElement.attr
                    'id': 'note-rect-' + @model.id
                    'width': 150
                    'height': 25
                    'fill': @model.get('color')?.getText() or 'gray'
                    'stroke': 'black'
                    'data-type': 'note-rect'
                    'data-object-id': @model.id

            unless @titleElement
                @titleElement = @d3el.append('text') if not @titleElement
                @titleElement.attr
                    'id': 'note-title-' + @model.id
                    'style': 'fill:white;stroke:none'
                    'x': 5
                    'y': 18
                    'font-size': 12
                    'data-type': 'title'
                    'data-object-id': @model.id

            @titleElement.text title

