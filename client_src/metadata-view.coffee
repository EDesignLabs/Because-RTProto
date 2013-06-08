define ['title-view', 'description-view'], (TitleView, DescriptionView)->
    MetadataView = Backbone.View.extend
        className: 'metadata'

        events:
            'click .display-context-creator': 'onClickDisplayContextCreator'
            'click .save-context': 'onClickSaveContext'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @data = @model.context.get 'data'

            @creator = $("#context-creator")
            @imageUrl = @creator.find("input[name='url']")
            @documentTitle = @creator.find("input[name='title']")
            @documentDesc = @creator.find("textarea[name='desc']")

            $('.display-context-creator').show() if @model.user.isOwner()
            @populateForm() if @model.user.isOwner()

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

        populateForm: ->
            @imageUrl.val @data.get('image').getText()
            @documentTitle.val @data.get('title').getText()
            @documentDesc.val @data.get('desc').getText()

        onClickDisplayContextCreator: (ev)->
            if @model.user.isOwner()
                @creator.modal
                    'show': true

        onClickSaveContext: (ev)->
            if @model.user.isOwner()
                @data.get('image').setText @imageUrl.val()
                @data.get('title').setText @documentTitle.val()
                @data.get('desc').setText @documentDesc.val()
                @model.context.get('owner').get('userId').setText @model.user.userId
                @model.context.get('owner').get('color').setText @model.user.color

                @creator.modal 'hide'
