define ['collaborator-view'], (CollaboratorView)->
    CollaboratorsView = Backbone.View.extend
        el: "#collaborators"

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @model.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_JOINED, (rtEvent)=>
                @onCollaboratorsJoined(rtEvent)
            @model.addEventListener gapi.drive.realtime.EventType.COLLABORATOR_LEFT, (rtEvent)=>
                @onCollaboratorsLeft(rtEvent)

        render: ->
            _.each @model.getCollaborators(), (collaborator)=>
                @createCollaborator collaborator

        createCollaborator: (collaborator)->
            collaboratorView = new CollaboratorView
                model: collaborator
                dispatcher: @dispatcher

            @$el.append collaboratorView.$el
            collaboratorView.render()

        onCollaboratorsJoined: (rtEvent) ->
            @createCollaborator rtEvent.collaborator

        onCollaboratorsLeft: (rtEvent) ->
            collaboratorElement = @$el.children("#collaborator-#{rtEvent.collaborator.userId}").last()
            collaboratorElement.slideUp 'slow', ->
                collaboratorElement.remove()