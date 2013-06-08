define ["d3view"], (D3View)->
    ContextView = D3View.extend
        tagName: 'image'
        className: 'context'

        initialize: (options)->
            D3View::initialize.call @,options
            @dispatcher = options.dispatcher

            @model.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTextInserted, this

        onTextInserted: ->
            @render()

        render: ->
            # totes cray cray image dimension finding hack
            backgroundImage = $ "<img src=\"#{@model.getText()}\" style=\"visibility:hidden\">"

            $("body").append backgroundImage

            width = backgroundImage.width()
            height = backgroundImage.height()

            backgroundImage.remove()

            @dispatcher.trigger('context:image-load', @model.getText(), width, height)

            @d3el.attr
                'xlink:href': @model.getText()
                x: '0'
                y: '0'
                height: '100%'
                width: '100%'
                preserveAspectRatio: 'xMinYMin meet'
                viewBox: "0 0 #{width} #{height}"
