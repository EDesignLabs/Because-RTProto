define ->
    DescriptionView = Backbone.View.extend

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher
            @model.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, this

        render: (options)->
            @$el.text @model.getText()

        onDescriptionChanged: (rtEvent)->
            @$el.text @model.getText()