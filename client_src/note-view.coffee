define ['d3view', 'handle-view'], (D3View, HandleView)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.get('x').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, this
            @model.get('y').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, this
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTitleChanged, this
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, this

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @

        onHandlePositionChanged: (rtEvent)->
            @d3el.attr
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

        onTitleChanged: (rtEvent)->
            debugger

        onDescriptionChanged: (rtEvent)->
            debugger

        onToolEngage: (ev, tool)->
            target = d3.select ev.target
            
            if target.attr('data-object-id') is @model.id and target.attr('data-type') is 'note-rect'
                @dispatcher.trigger 'note:delete', @model if tool is 'delete'
                
                if tool is 'move' 
                    @engaged = true             
                    matrix = @d3el.attr('transform').slice(7, -1).split(' ')
                    x = if matrix[4] isnt 'NaN' then parseInt matrix[4],10 else 0
                    y = if matrix[5] isnt 'NaN' then parseInt matrix[5],10 else 0
                    @offsetX = ev.clientX - @el.offsetLeft - x
                    @offsetY = ev.clientY - @el.offsetTop - y

        onToolMove: (ev, tool)->
            target = d3.select ev.target
            
            if @engaged
                if tool is 'move'
                    x = ev.clientX - @el.offsetLeft - @offsetX
                    y = ev.clientY - @el.offsetTop - @offsetY
                    @d3el.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"

        onToolRelease: (ev, tool)->
            target = d3.select ev.target

            if @engaged 
                if tool is 'move'
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

            @noteRectElement = @d3el.append 'rect' if not @noteRectElement
            @noteRectElement.attr
                'id': 'note-rect-' + @model.id
                'width': 100
                'height': 50
                'fill': if @model.get('selected').getText() is 'true' then 'white' else 'lightsteelblue'
                'stroke': @model.get('color')?.getText() or 'gray'
                'data-type': 'note-rect'
                'data-object-id': @model.id

            @titleElement = @d3el.append('text').text @model.get('title').getText() if not @titleElement
            @titleElement.attr
                'id': 'note-title-' + @model.id
                'style': 'fill:black;stroke:none'
                'x': 5
                'y': 15
                'font-size': 12
                'data-type': 'title'
                'data-object-id': @model.id

            @descElement = @d3el.append('text').text @model.get('desc').getText() if not @descElement
            @descElement.attr
                'id': 'note-desc-' + @model.id
                'style': 'fill:blue;stroke:none'
                'x': 5
                'y': 30
                'width': 50
                'height': 'auto'
                'font-size': 8
                'data-type': 'note-rect'
                'data-object-id': @model.id

            if not @handleView
                @handleView = new HandleView
                    model: @model
                    parent: @d3el
                    dispatcher: @dispatcher

                @handleView.render()
