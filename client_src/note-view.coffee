define ['d3view', 'handle-view'], (D3View, HandleView)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.addEventListener gapi.drive.realtime.EventType.OBJECT_CHANGED, _.bind @onObjectChanged, this

        onObjectChanged: ->
            @render()

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

                @handleView.render()
