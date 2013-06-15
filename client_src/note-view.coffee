define ['d3view', 'handle-view'], (D3View, HandleView)->
    NoteView = D3View.extend
        tagName: 'g'

        initialize: (options)->
            @doc = options.doc

            @constructor.__super__.initialize.call @,options
            @model.get('x').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, @
            @model.get('y').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onHandlePositionChanged, @
            @model.get('color').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onColorChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind @onDescriptionChanged, @
            @model.get('title').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onTitleChanged, @
            @model.get('desc').addEventListener gapi.drive.realtime.EventType.TEXT_DELETED, _.bind @onDescriptionChanged, @

            @model.get('comments')?.addEventListener gapi.drive.realtime.EventType.VALUES_ADDED, _.bind @onCommentsAdded, @
            @model.get('comments')?.addEventListener gapi.drive.realtime.EventType.VALUES_REMOVED, _.bind @onCommentsRemoved, @

            @dispatcher.on 'tool:engage', _.bind @onToolEngage, @
            @dispatcher.on 'tool:move', _.bind @onToolMove, @
            @dispatcher.on 'tool:release', _.bind @onToolRelease, @
            @dispatcher.on 'collaborator:selected', _.bind @onCollaboratorSelected, @
            @dispatcher.on 'note:highlight', _.bind @onNoteHighlight, @
            @dispatcher.on 'note:unhighlight', _.bind @onNoteUnhighlight, @

            @highlighted is no

        # model callbacks

        onHandlePositionChanged: (rtEvent)->
            @d3el.transition().duration(400).attr
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"

        onTitleChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") isnt ''
                abridgedTitle = @model.get('title').getText().substr(0,18)
                abridgedTitle += '...' if @model.get('title').getText().length > 18
                @renderTitle(abridgedTitle)
            else
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") is ''
                    @noteRectElement.remove() if @noteRectElement
                    @titleElement.remove() if @titleElement
                    delete @noteRectElement if @noteRectElement
                    delete @titleElement if @titleElement
                else
                    abridged = @model.get('desc').getText().substr(0,15) + '...'
                    @renderTitle(abridged)

        onDescriptionChanged: (rtEvent)->
            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") is ''
                if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                    abridged = @model.get('desc').getText().substr(0,15) + '...'
                    @renderTitle(abridged)
                else
                    @noteRectElement.remove() if @noteRectElement
                    @titleElement.remove() if @titleElement
                    delete @noteRectElement if @noteRectElement
                    delete @titleElement if @titleElement

        onColorChanged: (rtEvent)->
            @noteRectElement.attr
                'fill': @model.get('color').getText() || 'gray'

        onCommentsAdded: (rtEvent)->
            _.each rtEvent.values, (comment)->
                @addComment comment
            , @

        onCommentsRemoved: (rtEvent)->
            _.each rtEvent.values, (comment)->
                @removeComment comment
            , @

        # view callbacks

        onToolEngage: (ev, tool)->
            target = d3.select ev.target

            if target.attr('data-object-id') is @model.id and (target.attr('data-type') in ['note-rect', 'title', 'comment-rect', 'comment-count'])

                if @model.get('userId').getText() isnt '' and @model.get('userId').getText() isnt tool.user.userId and not tool.user.isOwner()
                    @dispatcher.trigger 'note:view', d3.event, @model if tool.type is 'marker'

                else
                    #user-restricted actions are below here

                    @dispatcher.trigger 'note:delete', @model if tool.type is 'delete'

                    @dispatcher.trigger 'note:edit', d3.event, @model if tool.type is 'marker'

                    if tool.type is 'move'
                        @engaged = true
                        matrix = @d3el.attr('transform').slice(7, -1).split(' ')
                        x = if matrix[4] isnt 'NaN' then parseInt matrix[4],10 else 0
                        y = if matrix[5] isnt 'NaN' then parseInt matrix[5],10 else 0
                        @offsetX = ev.clientX - @el.offsetLeft - x
                        @offsetY = ev.clientY - @el.offsetTop - y


        onToolMove: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if tool.type is 'move'
                    x = ev.clientX - @el.offsetLeft - @offsetX
                    y = ev.clientY - @el.offsetTop - @offsetY
                    @d3el.attr 'transform', "matrix(1 0 0 1 #{x} #{y})"
            else
                if target.attr('data-object-id') is @model.id
                    @dispatcher.trigger 'note:highlight', @model unless @highlighted
                else
                    @dispatcher.trigger 'note:unhighlight', @model if @highlighted

        onToolRelease: (ev, tool)->
            target = d3.select ev.target

            if @engaged
                if @model.get('userId').getText() is '' and not tool.user.isOwner()
                    @model.get('userId').setText tool.user.userId
                    @model.get('color').setText tool.user.color

                if tool.user.isOwner()
                    @model.get('userId').setText ''
                    @model.get('color').setText 'gray'

                if tool.type is 'move'
                    matrix = @d3el.attr('transform').slice(7, -1).split(' ')
                    @doc.getModel().beginCompoundOperation()
                    @model.get('x').setText matrix[4]
                    @model.get('y').setText matrix[5]
                    @doc.getModel().endCompoundOperation()

                    @engaged = false

        onCollaboratorSelected: (collaborator)->
            if collaborator.userId is @model.get('userId').getText() and @noteRectElement? and @titleElement?
                @blink()

        onNoteHighlight: (model)->
            if model.id is @model.id
                @highlight()

        onNoteUnhighlight: (model)->
            if model.id is @model.id
                @unhighlight()

        # actions

        updateCommentCount: ->
            if @model.get('comments')?.length > 0
                unless @commentRectElement
                    @commentRectElement = @d3el.append 'rect'
                    @commentRectElement.attr
                        'width': 20
                        'height': 25
                        'x': -20
                        'fill': 'white'
                        'stroke': 'black'
                        'data-type': 'comment-rect'
                        'data-object-id': @model.id

                unless @commentCountElement
                    @commentCountElement = @d3el.append 'text'
                    @commentCountElement.attr
                        'width': 20
                        'height': 25
                        'x': -15
                        'y': 17
                        'font-size': 10
                        'fill': 'black'
                        'stroke': 'none'
                        'data-type': 'comment-count'
                        'data-object-id': @model.id

                @commentCountElement.text @model.get('comments').length + ''

        addComment: (comment)->
            @updateCommentCount()
            @dispatcher.trigger 'note:add-comment', @model, comment

        removeComment: (comment)->
            @dispatcher.trigger 'note:remove-comment', @model, comment

        blink: ->
            @noteRectElement?.transition().attr('fill','white').duration(200)
            @titleElement?.transition().attr('fill','black').duration(200)
            @noteRectElement?.transition().attr('fill',@model.get('color')?.getText() or 'gray').delay(500).duration(200)
            @titleElement.transition().attr('fill','white').delay(500).duration(200)

        highlight: ->
            @noteRectElement?.transition().attr('fill','white').duration(200)
            @titleElement?.transition().attr('fill','black').duration(200)
            @highlighted = yes

        unhighlight: ->
            @noteRectElement?.transition().attr('fill',@model.get('color')?.getText() or 'gray').duration(200)
            @titleElement?.transition().attr('fill','white').duration(200)
            @highlighted = no

        render: ->
            @d3el.attr
                'id': 'note-' + @model.id
                'x': 0
                'y': 0
                'transform': "matrix(1 0 0 1 #{@model.get('x').getText()} #{@model.get('y').getText()})"
                'data-type': 'note'
                'data-object-id': @model.id

            abridgedTitle = @model.get('title').getText().substr(0,18)
            abridgedTitle += '...' if @model.get('title').getText().length > 18
            abridgedDesc = @model.get('desc').getText().substr(0,18) + '...'

            if not @handleView
                @handleView = new HandleView
                    doc: @doc
                    model: @model
                    parent: @d3el
                    dispatcher: @dispatcher

                @handleView.render()

            if @model.get('title').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderTitle(abridgedTitle)
            else if @model.get('desc').getText().replace(/^\s+|\s+$/g, "") isnt ''
                @renderTitle(abridgedDesc)

            @updateCommentCount()

        renderTitle: (title)->
            unless @noteRectElement
                @noteRectElement = @d3el.append 'rect' if not @noteRectElement
                @noteRectElement.attr
                    'id': 'note-rect-' + @model.id
                    'width': 150
                    'height': 25
                    'fill': @model.get('color')?.getText() or 'gray'
                    'stroke': 'black'
                    'data-type': 'note-rect'
                    'data-object-id': @model.id

            unless @titleElement
                @titleElement = @d3el.append('text') if not @titleElement
                @titleElement.attr
                    'id': 'note-title-' + @model.id
                    'fill': 'white'
                    'stroke': 'none'
                    'x': 5
                    'y': 18
                    'font-size': 12
                    'data-type': 'title'
                    'data-object-id': @model.id

            @titleElement.text title

