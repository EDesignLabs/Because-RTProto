define ['toolbar-view', 'add-view'], (ToolbarView, AddView)->
    ControlView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

        render: (options)->
            @toolbarView = new ToolbarView
                model: @model
                dispatcher: @dispatcher
                el: $el('.toolbar')

            @addView = new AddView
                model: @model
                dispatcher: @dispatcher
                el: $el('.add')
