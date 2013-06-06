define ['toolbar-view', 'add-view', 'metadata-view'], (ToolbarView, AddView, MetadataView)->
    ControlView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

        render: (options)->
            @metadataView = new MetadataView
                model: @model.get 'data'
                dispatcher: @dispatcher
                el: @$el.find('.metadata')

            @toolbarView = new ToolbarView
                model: @model.get 'context'
                dispatcher: @dispatcher
                el: @$el.find('.toolbar')

            @addView = new AddView
                model: @model.get 'context'
                dispatcher: @dispatcher
                el: @$el.find('.add')

            @metadataView.render()
            @toolbarView.render()
            @addView.render()
