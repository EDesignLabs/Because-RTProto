define ['toolbar-view', 'metadata-view'], (ToolbarView, MetadataView)->
    ControlView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @collaborators = @model.getCollaborators()
            @context = @model.getModel().getRoot().get('context')
            @data = @context.get 'data'
            @notes = @context.get 'notes'
            @user = @getMe()

            @addNoteButton = $ "#add-note"
            @editNoteButton = $ "#edit-note"

            @dispatcher.on 'context:image-load', (url, width, height)=>
                @backgroundWidth = width
                @backgroundHeight = height
                @backgroundUrl = url

            @dispatcher.on 'marker:add', (ev, context)=>
                $ev =
                    data:
                        d3ev: ev

                @onAddNoteClick $ev

            @dispatcher.on 'note:add', (ev, context)=>
                @addNoteButton.on 'click', {d3ev:ev}, _.bind @onAddNoteClick, @

                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")

                creator.toggleClass 'add', yes
                creator.toggleClass 'edit', no
                creator.toggleClass 'view', no

                creator.modal
                    'show': yes

                creator.css
                    'left': ev.x
                    'top': ev.y

                creatorTitle.text "New Note"

            @dispatcher.on 'note:edit', (ev, model)=>
                @editNoteButton.on 'click', {model:model}, _.bind @onEditNoteClick, @

                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")
                title = $("#title")
                url = $("#url")
                desc = $("#desc")

                creator.toggleClass 'add', no
                creator.toggleClass 'edit', yes
                creator.toggleClass 'view', no

                creator.modal
                    'show': yes

                creator.css
                    'left': ev.x
                    'top': ev.y

                creatorTitle.text model.get('title').getText()

                title.val model.get('title').getText()
                url.val  model.get('url').getText()
                desc.val model.get('desc').getText()

            @dispatcher.on 'note:view', (ev, model)=>
                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")
                url = $(".view .url")
                desc = $(".view .description")
                thumbnail = creator.find '.thumbnail'

                url.text model.get('url').getText()
                url.attr 'href', model.get('url').getText()
                desc.text model.get('desc').getText()

                creator.toggleClass 'add', no
                creator.toggleClass 'edit', no
                creator.toggleClass 'view', yes

                creator.modal
                    'show': true

                creator.css
                    'left': ev.x
                    'top': ev.y

                width = parseInt(@backgroundWidth) - 150
                height = parseInt(@backgroundHeight) - 150
                thumbnailX = parseInt(model.get('x').getText(), 10) + parseInt(model.get('hx').getText(), 10) - 75
                thumbnailY = parseInt(model.get('y').getText(), 10) + parseInt(model.get('hy').getText(), 10) - 75

                thumbnail.css 'background-image', "url('#{@backgroundUrl}')"
                thumbnail.css 'background-size', "#{width}px #{height}px"
                thumbnail.css 'background-position-x', "#{thumbnailX/width*100}%"
                thumbnail.css 'background-position-y', "#{thumbnailY/height*100}%"

                creator

                creatorTitle.text model.get('title').getText()


        render: (options)->
            @metadataView = new MetadataView
                model:
                    context: @context
                    user: @user
                dispatcher: @dispatcher
                el: @$el.find '.metadata'

            @toolbarView = new ToolbarView
                model: @user
                dispatcher: @dispatcher
                el: @$el.find '.toolbar'

            @metadataView.render()
            @toolbarView.render()

        getMe: () ->
            me = _.filter(@collaborators, (item)-> item.isMe)[0]
            owner = @context.get('owner')

            me.isOwner = ()->
                #if I am the owner (or no one is)
                me.userId is owner.get('userId').getText() or not owner.get('userId').getText()

            me

        onAddNoteClick: (ev)->
            x = ev.data.d3ev.offsetX
            y = ev.data.d3ev.offsetY
            creator = $("#note-creator")

            title = $("#title")
            url = $("#url")
            desc = $("#desc")

            newNote = @model.getModel().createMap
                title: @model.getModel().createString title.val()
                desc: @model.getModel().createString desc.val()
                url: @model.getModel().createString url.val()
                x: @model.getModel().createString (x-75) + ''
                y: @model.getModel().createString y + ''
                hx: @model.getModel().createString '75'
                hy: @model.getModel().createString '-10'
                selected: @model.getModel().createString 'false'
                userId: @model.getModel().createString @user.userId
                color: @model.getModel().createString @user.color

            @notes.push newNote

            title.val ''
            desc.val ''
            url.val ''

            creator.modal 'hide'
            @addNoteButton.off 'click'

        onEditNoteClick: (ev)->
            model = ev.data.model
            creator = $("#note-creator")

            title = $("#title")
            url = $("#url")
            desc = $("#desc")

            model.get('title').setText title.val()
            model.get('desc').setText desc.val()
            model.get('url').setText url.val()

            title.val ''
            desc.val ''
            url.val ''

            creator.modal 'hide'
            @editNoteButton.off 'click'


