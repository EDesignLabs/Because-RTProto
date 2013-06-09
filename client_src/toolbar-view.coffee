define ->
    ToolbarView = Backbone.View.extend

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @markerTool = @$el.find '#marker-tool'
            @moveTool = @$el.find '#move-tool'
            @deleteTool = @$el.find '#delete-tool'

            @markerTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @model

            @moveTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'move'
                user: @model

            @deleteTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'delete'
                user: @model

            @dispatcher.on 'tool:set', (tool)=>
                @markerTool.toggleClass 'active', tool.type is 'marker'
                @moveTool.toggleClass 'active', tool.type is 'move'
                @deleteTool.toggleClass 'active', tool.type is 'delete'

            @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @model
