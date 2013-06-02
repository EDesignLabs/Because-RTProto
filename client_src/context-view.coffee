define ["d3view"], (D3View)->
    ContextView = D3View.extend
        tagName: 'image'

        initialize: (options)->
            @constructor.__super__.initialize.call @,options
            @model.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTextInserted, this

        onTextInserted: ->
            @render()

        render: ->
            @d3el.attr 'xlink:href', @model.getText()
            @d3el.attr 'x', "0"
            @d3el.attr 'y', "0"
            @d3el.attr 'height', "100%"
            @d3el.attr 'width', "100%"
