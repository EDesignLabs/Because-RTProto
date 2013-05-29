define ["d3view"], (D3View)->
    MarkerView = D3View.extend
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
                'data-type': 'marker'
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

            @markerCircleElement = @d3el.append 'circle' if not @markerCircleElement
            @markerCircleElement.attr
                'r': 5
                'cx': 5
                'cy': 5
                'data-type': 'marker-circle'
                'fill': @model.get('color')?.getText() or 'gray'
                'stroke': 'none'
