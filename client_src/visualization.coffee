define "visualization", () ->
    
  # The Y-Axis will be lazily instantiated if needed.
  pullDataFromGoogleSpreadsheet = (url) ->
    Tabletop.init
      key: url
      callback: generateGraph
      simpleSheet: true

  generateGraph = (dataset, tabletop) ->
    workspace = document.querySelector ".workspace-container"
    
    keys = _.keys dataset[0]
    labels =
      x: keys[0].charAt(0).toUpperCase() + keys[0].slice(1)
      y: keys[1].charAt(0).toUpperCase() + keys[1].slice(1)

    dataset = _.map dataset, (data, key) ->
      x: parseInt(data[keys[0]], 10)
      y: parseFloat(data[keys[1]], 10)
      
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
        pullDataFromGoogleSpreadsheet "https://docs.google.com/spreadsheet/pub?key=0Ar2Io2uAtw9TdEFvb2t5U3BiZDhQRlNSRjRTY3Q2Rmc&output=html"
        callback() if callback?
  }
