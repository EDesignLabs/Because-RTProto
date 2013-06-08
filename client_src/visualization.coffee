define "visualization", ->
  
  # TODO: Update the graph with Tabletop data when it's available
  # TODO: Add the ability to update the graph
  # TODO: Add the ability to replace the graph
    
  pullDataFromGoogleSpreadsheet = (url) ->
    Tabletop.init
      key: url
      callback: generateGraph
      simpleSheet: true

  generateGraph = (dataset, tabletop) ->
    workspace = document.querySelector ".workspace-container"
    
    # TODO: This needs to be refactored badly
    if dataset?
      keys = _.keys dataset[0]
      labels =
        x: keys[0].charAt(0).toUpperCase() + keys[0].slice(1)
        y: keys[1].charAt(0).toUpperCase() + keys[1].slice(1)

      dataset = _.map dataset, (data, key) ->
        x: parseInt(data[keys[0]], 10)
        y: parseFloat(data[keys[1]], 10)
    else
      dataset = [
        x: 0
        y: 0
      ]
      labels =
        x: "X-Axis"
        y: "Y-Axis"
      
    graph = new Rickshaw.Graph
      element: workspace
      width: 960
      height: 600
      series: [
        color: "#00ADEF"
        stroke: "rgba(0,0,0,0.15)"
        name: labels.y
        data: dataset
      ]

    graph.render()
    
    hoverDetail = new Rickshaw.Graph.HoverDetail
      graph: graph
      xFormatter: (x) ->
        labels.x + ": " + x
      yFormatter: (y) ->
        y

    yAxis = new Rickshaw.Graph.Axis.Y
      graph: graph
      orientation: "left"
      element: document.getElementById("y-axis")

    xAxis = new Rickshaw.Graph.Axis.X(graph: graph)
    yAxis.render()
    xAxis.render()
  
  return {
      initialize: (callback) -> 
        generateGraph()
        callback() if callback?
  }
