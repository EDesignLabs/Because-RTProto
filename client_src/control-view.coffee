define ['toolbar-view', 'metadata-view', 'comment-view'], (ToolbarView, MetadataView, CommentView)->
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
            @addCommentButton = $ "#add-comment"
            @showCommentToggle = $ ".comments-header"

            @dispatcher.on 'context:image-load', (url, width, height)=>
                @backgroundWidth = width
                @backgroundHeight = height
                @backgroundUrl = url

            @dispatcher.on 'marker:add', (ev, context)=>
                $ev =
                    data:
                        d3ev: ev

                @onAddNoteClick $ev

            @dispatcher.on 'note:edit', (ev, model)=>
                @dispatcher.off 'note:add-comment'
                @editNoteButton.off 'click'
                @addCommentButton.off 'click'
                @editNoteButton.on 'click', {model:model}, _.bind @onEditNoteClick, @
                @addCommentButton.on 'click', {model:model}, _.bind @onAddCommentClick, @
                @showCommentToggle.on 'click', =>
                    $('#comment-creator').slideDown()
                    @showCommentToggle.toggleClass('expanded', true)

                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")
                title = $("#title")
                url = $("#url")
                desc = $("#desc")
                thumbnail = creator.find '.thumbnail'
                creator.find(".comments").empty()

                if model.get('comments')?.length > 0
                    $(".comments-header .count").text model.get('comments').length + ' '
                    _.each model.get('comments').asArray(), (comment)->
                        @addComment model, comment
                    , @
                else
                    $(".comments-header .count").text ''

                @dispatcher.on 'note:add-comment', (model, comment)=>
                    @addComment model, comment

                creator.toggleClass 'add', no
                creator.toggleClass 'edit', yes
                creator.toggleClass 'view', no

                creator.modal
                    'show': yes

                creator.css
                    'left': ev.x
                    'top': if ev.y < 200 then ev.y else 200

                x = (parseInt(model.get('x').getText(), 10) + parseInt(model.get('hx').getText(), 10))
                y = (parseInt(model.get('y').getText(), 10) + parseInt(model.get('hy').getText(), 10))

                @centerThumbnail x, y

                creatorTitle.text model.get('title').getText()

                title.val model.get('title').getText()
                url.val  model.get('url').getText()
                desc.val model.get('desc').getText()

                creator.on 'hidden', (ev)=> @onModalHidden ev

            @dispatcher.on 'note:view', (ev, model)=>
                @showCommentToggle.on 'click', =>
                    $('#comment-creator').slideDown()
                    @showCommentToggle.toggleClass('expanded', true)
                @addCommentButton.on 'click', {model:model}, _.bind @onAddCommentClick, @

                creator = $("#note-creator")
                creatorTitle = $("#note-creator-title")
                url = $(".view .url")
                desc = $(".view .description")
                creator.find(".comments").empty()

                if model.get('comments')?.length > 0
                    $(".comments-header .count").text model.get('comments').length + ' '
                    _.each model.get('comments').asArray(), (comment)->
                        @addComment model, comment
                    , @
                else
                    $(".comments-header .count").text ''

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
                    'top': if ev.y < 200 then ev.y else 200

                x = (parseInt(model.get('x').getText(), 10) + parseInt(model.get('hx').getText(), 10))
                y = (parseInt(model.get('y').getText(), 10) + parseInt(model.get('hy').getText(), 10))

                @centerThumbnail x, y

                creatorTitle.text model.get('title').getText()

                creator.on 'hidden', (ev)=> @onModalHidden ev

            @timer = setInterval (=> @dispatcher.trigger 'time:update'), 5000

        addComment: (model, comment)->
            commentView = new CommentView
                model: comment
                dispatcher: @dispatcher

            $(".comments").append commentView.$el

            if model.get('comments')?.length > 0
                $(".comments-header .count").text model.get('comments').length + ' '
            else
                $(".comments-header .count").text ''


            commentView.render()

        centerThumbnail: (x, y)->
            thumbnail = $("#note-creator .thumbnail")

            svgWidth = $(".workspace-container svg").width()
            aspectRatio = parseInt(@backgroundWidth, 10)/parseInt(@backgroundHeight, 10)
            proportion = parseInt(@backgroundWidth, 10)/svgWidth
            svgHeight = svgWidth/aspectRatio

            width = svgWidth #- 150 * proportion
            height = svgHeight #- 150 * proportion
            thumbnailX = (x - 75) * -1
            thumbnailY = (y - 75) * -1

            thumbnail.css 'background-image', "url('#{@backgroundUrl}')"
            thumbnail.css 'background-size', "#{svgWidth}px #{svgHeight}px"
            thumbnail.css 'background-position-x', "#{thumbnailX}px"
            thumbnail.css 'background-position-y', "#{thumbnailY}px"


        render: (options)->
            @metadataView = new MetadataView
                model:
                    context: @context
                    user: @user
                dispatcher: @dispatcher
                el: @$el.find '.metadata'

            @toolbarView = new ToolbarView
                model:
                    context: @context
                    user: @user
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
                comments: @model.getModel().createList()

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
            @addCommentButton.off 'click'
            @dispatcher.off 'note:add-comment'

        onAddCommentClick: (ev)->
            model = ev.data.model
            creator = $("#comment-creator")

            comment = @model.getModel().createMap
                body: @model.getModel().createString $('#note-comment').val()
                userId: @model.getModel().createString if @user.isOwner() then '' else @user.userId
                displayName: @model.getModel().createString @user.displayName
                photoUrl: @model.getModel().createString @user.photoUrl
                color: @model.getModel().createString @user.color
                created: @model.getModel().createString (new Date()).toISOString()

            unless model.get 'comments'
                model.set 'comments', @model.getModel().createList()

            model.get('comments').push comment
            $('#note-comment').val ''

        onModalHidden: (ev)->
            $("#title").val ''
            $("#desc").val ''
            $("#url").val ''
            $('#note-comment').val ''

            $('button.close-button').removeClass 'active'
            $('#comment-creator').slideUp()
            @showCommentToggle.toggleClass('expanded', false)

            @addNoteButton.off 'click'
            @editNoteButton.off 'click'
            @addCommentButton.off 'click'
            @dispatcher.off 'note:add-comment'

            @dispatcher.trigger 'tool:set',
                type: 'marker'
                user: @user

