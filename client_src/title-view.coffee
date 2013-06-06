define ->
    TitleView = Backbone.View.extend

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher
            @model.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTitleChanged, this

        render: (options)->
            debugger
            @$el.text @model.getText()

        onTitleChanged: (rtEvent)->
            @$el.text @model.getText()