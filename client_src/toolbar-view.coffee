define ->
    ToolbarView = Backbone.View.extend

        events:
            'click .display-context-creator': 'onClickDisplayContextCreator'
            'click .save-context': 'onClickSaveContext'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @data = @model.context.get 'data'

            @creator = $ "#context-creator"
            @imageUrl = @creator.find("input[name='url']")
            @documentTitle = @creator.find("input[name='title']")
            @documentDesc = @creator.find("textarea[name='desc']")

            @markerTool = @$el.find '#marker-tool'
            @moveTool = @$el.find '#move-tool'
            @deleteTool = @$el.find '#delete-tool'

            @markerTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @model.user

            @moveTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'move'
                user: @model.user

            @deleteTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'delete'
                user: @model.user

            @dispatcher.on 'tool:set', (tool)=>
                @markerTool.toggleClass 'active', tool.type is 'marker'
                @moveTool.toggleClass 'active', tool.type is 'move'
                @deleteTool.toggleClass 'active', tool.type is 'delete'

            @dispatcher.on 'workspace:request-tool', (tool)=>
                @dispatcher.trigger 'tool:set',
                    type: tool.type
                    user: @model.user

            @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @model.user

            $('.display-context-creator').show() if @model.user.isOwner()
            @populateForm() if @model.user.isOwner()

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
