define "visualization", ->

  parseLocation = (url) ->
    result =
      url: url.split('?')[0]
      hash: url.split('?')[1].split('#')[1]
      query: {}
  
    url.split('?')[1].split('#')[0].split('&').forEach (i) ->
      i = i.split('=')
      result.query[i[0]] = i[1]
  
    result

  class RickshawVisualization
    palette = new Rickshaw.Color.Palette( { scheme: 'spectrum2001' } );
    
    constructor: (options) ->
      @workspace = document.querySelector ".workspace-container"
      @graph = new Rickshaw.Graph
        element: @workspace
        width: 780
        height: 600
        series: new Rickshaw.Series([{ name: 'This' }])
      @yAxis = new Rickshaw.Graph.Axis.Y
        graph: @graph
        orientation: "left"
        element: document.getElementById("y-axis")
      @xAxis = new Rickshaw.Graph.Axis.X(graph: @graph)
      @graph.render()

    pullDataFromGoogleSpreadsheet: (url) ->
      visualization = @
      Tabletop.init
        key: url
        callback: @processTabletopResults.bind(visualization)
        simpleSheet: true
        
    processTabletopResults: (dataset, Tabletop) ->
      console.log(dataset)
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
      
      @appendDataToVisualization(data)
      
    appendDataToVisualization: (data) ->
      @graph.series.addData(data)
      @graph.update()
      
    renderAll: () ->
      @graph.render()
      @yAxis.render() if @yAxis?
      @xAxis.render() if @xAxis?
   
  return {
      initialize: (callback) -> 
        window.Visualization = new RickshawVisualization
        callback() if callback?
  }
