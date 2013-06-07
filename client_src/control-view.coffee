define ['toolbar-view', 'add-view', 'metadata-view'], (ToolbarView, AddView, MetadataView)->
    ControlView = Backbone.View.extend
        className: 'span12'

        initialize: (options)->
            Backbone.View::initialize.call @, options
            @dispatcher = options.dispatcher

            @collaborators = @model.getCollaborators()
            @data = @model.getModel().getRoot().get('context').get 'data'
            @notes = @model.getModel().getRoot().get('context').get 'notes'

            @addNoteButton = $ "#add-note"
            @editNoteButton = $ "#edit-note"

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

                creatorTitle.text model.get('title').getText()
                

        render: (options)->
            @metadataView = new MetadataView
                model: @data
                dispatcher: @dispatcher
                el: @$el.find '.metadata'

            @toolbarView = new ToolbarView
                model: @getMe()
                dispatcher: @dispatcher
                el: @$el.find '.toolbar'

            @addView = new AddView
                model: @getMe()
                dispatcher: @dispatcher
                el: @$el.find '.add'

            @metadataView.render()
            @toolbarView.render()
            @addView.render()

        getMe: () ->
            _.filter(@collaborators, (item)-> item.isMe)[0]

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
                userId: @model.getModel().createString @getMe().userId
                color: @model.getModel().createString @getMe().color

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


