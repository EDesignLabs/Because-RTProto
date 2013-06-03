define ["d3view"], (D3View)->
    MarkerView = D3View.extend
        tagName: 'g'
        engaged: false

        initialize: (options)->
            D3View::initialize.call @,options
            @model.get('x').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onPositionChanged, this
            @model.get('y').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onPositionChanged, this
            @model.get('color').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onColorChanged, this

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @

        onPositionChanged: (rtEvent)->
            @d3el.attr
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

        onColorChanged: (rtEvent)->
            @markerCircleElement.attr
                'fill': @model.get('color')?.getText() or 'gray'

        onToolEngage: (ev, tool)->
            target = d3.select ev.target
            
            if target.attr('data-object-id') is @model.id
                @dispatcher.trigger 'marker:delete', @model if tool is 'delete'
                
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
                'id': @model.id
                'x': 0
                'y': 0
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"
                'data-type': 'marker'
                'data-object-id': @model.id

            if not @markerCircleElement
                @markerCircleElement = @d3el.append 'circle'
                
                @markerCircleElement.attr
                    'r': 5
                    'cx': 5
                    'cy': 5
                    'fill': @model.get('color')?.getText() or 'gray'
                    'stroke': 'none'
                    'data-type': 'marker-circle'
                    'data-object-id': @model.id
