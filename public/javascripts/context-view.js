// Generated by CoffeeScript 1.3.3

define(["d3view"], function(D3View) {
  var ContextView;
  return ContextView = D3View.extend({
    tagName: 'image',
    initialize: function(options) {
      this.constructor.__super__.initialize.call(this, options);
      return this.model.addEventListener(gapi.drive.realtime.EventType.TEXT_INSERTED, _.bind(this.onTextInserted, this));
    },
    onTextInserted: function() {
      return this.render();
    },
    render: function() {
      this.d3el.attr('xlink:href', this.model.getText());
      this.d3el.attr('x', "0");
      this.d3el.attr('y', "0");
      this.d3el.attr('height', "100%");
      return this.d3el.attr('width', "100%");
    }
  });
});
