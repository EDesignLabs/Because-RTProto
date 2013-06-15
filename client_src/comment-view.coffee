define ->
    CommentView = Backbone.View.extend
        tagName: 'li'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher
            @model.get('body').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onBodyChanged, this
            @model.get('body').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onBodyChanged, this

            @dispatcher.on 'time:update', => @render()

        render: (options)->
            @$el.attr 'id', "comment-#{@model.id}"
            @$el.css 'background-color', @model.get('color').getText()
            @$el.html """#{ @model.get('body').getText() }
                <span class="display-name">#{ @model.get('displayName')?.getText() }</span>
                <span class="created">#{ moment(@model.get('created')?.getText()).fromNow() }</span>"""
            @$el.slideDown 'slow'

        onBodyChanged: (rtEvent)->
            @render()