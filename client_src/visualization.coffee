define "visualization", ->
  
  class RickshawVisualization
    constructor: (options) ->  
      @workspace = document.querySelector ".workspace-container"
      @graph = new Rickshaw.Graph
        element: @workspace
        width: 780
        height: 600
        series: [
          data: [{x: 0, y: 0}]
        ]
      @yAxis = new Rickshaw.Graph.Axis.Y
        graph: @graph
        orientation: "left"
        element: document.getElementById("y-axis")
      @xAxis = new Rickshaw.Graph.Axis.X(graph: @graph)
      @renderAll()

    pullDataFromGoogleSpreadsheet: (url) ->
      Tabletop.init
        key: url
        callback: @processTabletopResults.bind()
        simpleSheet: true
        
    processTabletopResults: (visualization, dataset, Tabletop) ->
      keys = _.keys dataset[0]
      
      labels =
        x: keys[0].charAt(0).toUpperCase() + keys[0].slice(1)
        y: keys[1].charAt(0).toUpperCase() + keys[1].slice(1)

      dataset = _.map dataset, (data, key) ->
        x: parseInt(data[keys[0]], 10)
        y: parseFloat(data[keys[1]], 10)
      
      @appendDataToVisualization(dataset, labels)
      
    appendDataToVisualization: (dataset, labels) ->
      graphData =
        name: labels.y
        data: dataset

      @graph.series.push(graphData)
      @renderAll()
      
    renderAll: () ->
      @graph.render()
      @yAxis.render() if @yAxis?
      @xAxis.render() if @xAxis?
      
   
  return {
      initialize: (callback) -> 
        window.Visualization = new RickshawVisualization
        callback() if callback?
  }
