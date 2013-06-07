define ->
    ToolbarView = Backbone.View.extend

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @viewTool = @$el.find '#view-tool'
            @markerTool = @$el.find '#marker-tool'
            @noteTool = @$el.find '#note-tool'
            @moveTool = @$el.find '#move-tool'
            @deleteTool = @$el.find '#delete-tool'

            @viewTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'view'
                user: @model

            @moveTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'move'
                user: @model

            @markerTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @model

            @noteTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'note'
                user: @model

            @deleteTool.click (e)=>
              @dispatcher.trigger 'tool:set',
                type: 'delete'
                user: @model

            @dispatcher.trigger 'tool:set',
                type: 'view'
                user: @model
