define ->
    D3View = Backbone.View.extend
        # cf http://nocircleno.com/blog/svg-with-backbone-js/
        _ensureElement: ->
            attrs = _.extend {}, _.result this, 'attributes'
            attrs.id = _.result(@, 'id') if @id
            attrs.class = _.result(@, 'className') if @className
            if !@el
                @d3el = this.options.parent?.append _.result(this, 'tagName')
                @d3el.attr attrs
                $el = $ @d3el.node()
                @setElement $el, false
            else
                if !@d3el
                    @d3el = d3.select _.result(@, 'el')
                    @d3el.attr attrs
                @setElement _.result(@, 'el'), false

