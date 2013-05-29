define ["d3view"], (D3View)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, _.bind @onObjectChanged, this

        onObjectChanged: ->
            @render()

        render: ->
            @d3el.attr
                'id': @model.id
                'x': 0
                'y': 0
                'data-type': 'note'
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

            @noteRectElement = @d3el.append 'rect' if not @noteRectElement
            @noteRectElement.attr
                'width': 100
                'height': 50
                'data-type': 'note-rect'
                'fill': if @model.get('selected').getText() is 'true' then 'white' else 'lightsteelblue'
                'stroke': @model.get('color')?.getText() or 'gray'

            @titleElement = @d3el.append('text').text @model.get('title').getText() if not @titleElement
            @titleElement.attr
                'style': 'fill:black;stroke:none'
                'x': 5
                'y': 15
                'font-size': 12

            @descElement = @d3el.append('text').text @model.get('desc').getText() if not @descElement
            @descElement.attr
                'style': 'fill:blue;stroke:none'
                'x': 5
                'y': 30
                'width': 50
                'height': 'auto'
                'font-size': 8

            @lineGroupElement = @d3el.append 'g' if not @lineGroupElement

            @lineElement = @lineGroupElement.append('line') if not @lineElement
            @lineElement.attr
                'x1': 100
                'y1': 25
                'x2': @model.get('hx').getText() || 200
                'y2': @model.get('hy').getText() || 25
                'stroke': 'black'
                'strokeWidth': 2
                'opacity': if @model.get('selected').getText() is 'true' then 0.0 else 1.0

            @handleElement = @lineGroupElement.append('circle') if not @handleElement
            @handleElement.attr
                'r': 5
                'cx': @model.get('hx').getText() || 200
                'cy': @model.get('hy').getText() || 25
                'fill': @model.get('color')?.getText() or 'gray'
                'stroke': if @model.get('selected').getText() is 'true' then 'black' else 'darkslateblue'
                'strokeWidth': 10
                'data-type': 'handle'
