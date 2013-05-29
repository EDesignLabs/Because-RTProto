define ->
    D3View = Backbone.View.extend
        # cf http://nocircleno.com/blog/svg-with-backbone-js/
        _ensureElement: ->
            if !@el
                attrs = _.extend {}, _.result this, 'attributes'
                attrs.id = _.result(@, 'id') if @id
                attrs.class = _.result(@, 'className') if @className
                @d3el = this.options.svg?.append _.result(this, 'tagName')
                @d3el.attr attrs
                $el = $ @d3el.node()
                @setElement $el, false
            else
                @setElement _.result(@, 'el'), false
