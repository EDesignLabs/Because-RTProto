define ->
    DescriptionView = Backbone.View.extend

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher
            @model.addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, this

        render: (options)->
            @$el.html "<p>" + @model.getText().split("\n").join("</p><p>") + "</p>"

        onDescriptionChanged: (rtEvent)->
            @$el.html @model.getText().replace /\n/g, "</p>"