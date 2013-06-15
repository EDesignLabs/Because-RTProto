define ['title-view', 'description-view'], (TitleView, DescriptionView)->
    MetadataView = Backbone.View.extend
        className: 'metadata'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @data = @model.context.get 'data'

        render: (options)->
            @titleView = new TitleView
                model: @data.get 'title'
                dispatcher: @dispatcher
                el: @$el.find '.title'

            @descriptionView = new DescriptionView
                model: @data.get 'desc'
                dispatcher: @dispatcher
                el: @$el.find '.description'

            @titleView.render()

            @descriptionView.render()
