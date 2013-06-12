define "visualization", ->

  palette = new Rickshaw.Color.Palette( { scheme: 'colorwheel' } );
  
  parseLocation = (url) ->
    result = {}

    result['url'] = url.split('?')[0]
    result['hash'] = url.split('#')[1]
    result['query'] = {}
    
    if url.indexOf('?') > 0
      url.split('?')[1].split('#')[0].split('&').forEach (i) ->
        i = i.split('=')
        result.query[i[0]] = i[1]
  
    result

  class RickshawVisualization
    
    constructor: (data, labels) ->
      data = [data] if data
      @workspace = document.querySelector ".workspace-container"
      @graph = new Rickshaw.Graph
        element: @workspace
        width: 780
        height: 600
        series: data || new Rickshaw.Series([{ name: 'Data' }])
      @yAxis = new Rickshaw.Graph.Axis.Y
        graph: @graph
        orientation: "left"
        element: document.getElementById("y-axis")
      @xAxis = new Rickshaw.Graph.Axis.X(graph: @graph)
      @renderAll()
      
      @hoverDetail = new Rickshaw.Graph.HoverDetail 
        graph: @graph
        xFormatter: -> (x) 
          labels.x + ": " + x
        yFormatter: -> (y) y
      
    renderAll: () ->
      @graph.render()
      @yAxis.render() if @yAxis?
      @xAxis.render() if @xAxis?
      
    
  fetchGoogleSpreadsheet = (url) ->
    Tabletop.init
      key: url
      callback: processTabletopResults
      simpleSheet: true
      
  processTabletopResults = (dataset, Tabletop) ->
    keys = _.keys dataset[0]
    
    labels =
      x: keys[0].charAt(0).toUpperCase() + keys[0].slice(1)
      y: keys[1].charAt(0).toUpperCase() + keys[1].slice(1)
    
    dataset = _.map dataset, (data, key) ->
      x: parseInt(data[keys[0]], 10)
      y: parseFloat(data[keys[1]], 10)
    
    data =
      name: labels.y
      data: dataset.slice(1)
      color: palette.color()
      
    window.Visualization = new RickshawVisualization(data, labels) unless window.visualization
   
  return {
    initialize: (callback) ->
      url = parseLocation(window.location.toString())
      
      if url.query.spreadsheet
        fetchGoogleSpreadsheet url.query.spreadsheet
      else
        window.Visualization = new RickshawVisualization
        
      callback() if callback?
  }
