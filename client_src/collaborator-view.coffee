define ->
    CollaboratorView = Backbone.View.extend
        tagName: 'div'
        className: 'collaborator'

        events:
            'click': 'onClick'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

        render: (options)->
            @$el.attr 'id', "collaborator-#{@model.userId}"
            @$el.css 'background-color', @model.color
            @$el.text @model.displayName
            @$el.slideDown 'slow'

        onClick: (ev)->
            @dispatcher.trigger 'collaborator:selected', @model