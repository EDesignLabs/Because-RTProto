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

                @centerThumbnail ev.x, ev.y

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
                thumbnail = creator.find '.thumbnail'

                creator.toggleClass 'add', no
                creator.toggleClass 'edit', yes
                creator.toggleClass 'view', no

                creator.modal
                    'show': yes

                creator.css
                    'left': ev.x
                    'top': ev.y

                x = (parseInt(model.get('x').getText(), 10) + parseInt(model.get('hx').getText(), 10))
                y = (parseInt(model.get('y').getText(), 10) + parseInt(model.get('hy').getText(), 10))

                @centerThumbnail x, y

                creatorTitle.text model.get('title').getText()

                title.val model.get('title').getText()
                url.val  model.get('url').getText()
                desc.val model.get('desc').getText()

            @dispatcher.on 'note:view', (ev, model)=>
                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")
                url = $(".view .url")
                desc = $(".view .description")

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

                x = (parseInt(model.get('x').getText(), 10) + parseInt(model.get('hx').getText(), 10))
                y = (parseInt(model.get('y').getText(), 10) + parseInt(model.get('hy').getText(), 10))

                @centerThumbnail x, y

                creatorTitle.text model.get('title').getText()

        centerThumbnail: (x, y)->
            thumbnail = $("#note-creator .thumbnail")

            svgWidth = $(".workspace-container svg").width()
            aspectRatio = parseInt(@backgroundWidth, 10)/parseInt(@backgroundHeight, 10)
            proportion = parseInt(@backgroundWidth, 10)/svgWidth
            svgHeight = svgWidth/aspectRatio

            width = svgWidth #- 150 * proportion
            height = svgHeight #- 150 * proportion
            thumbnailX = x - 75
            thumbnailY = y - 75

            thumbnail.css 'background-image', "url('#{@backgroundUrl}')"
            thumbnail.css 'background-size', "#{svgWidth}px #{svgHeight}px"
            thumbnail.css 'background-position-x', "-#{thumbnailX}px"
            thumbnail.css 'background-position-y', "-#{thumbnailY}px"


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
                y: @model.getModel().createString (y+10) + ''
                hx: @model.getModel().createString '75'
                hy: @model.getModel().createString '-10'
                selected: @model.getModel().createString 'false'
                userId: @model.getModel().createString if @user.isOwner() then '' else @user.userId
                color: @model.getModel().createString if @user.isOwner() then 'gray' else @user.color

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

            if model.get('userId').getText() is '' and not @user.isOwner()
                model.get('userId').setText @user.userId
                model.get('color').setText @user.color

            title.val ''
            desc.val ''
            url.val ''

            creator.modal 'hide'
            @editNoteButton.off 'click'


