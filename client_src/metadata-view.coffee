define ['title-view', 'description-view'], (TitleView, DescriptionView)->
    MetadataView = Backbone.View.extend
        className: 'metadata'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

        render: (options)->
            @titleView = new TitleView
                model: @model.get 'title'
                dispatcher: @dispatcher
                el: @$el.find '.title'

            @descriptionView = new DescriptionView
                model: @model.get 'desc'
                dispatcher: @dispatcher
                el: @$el.find '.description'

            @titleView.render()

            @descriptionView.render()