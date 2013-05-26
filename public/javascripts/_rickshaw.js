$(document).ready(function () {

  var $dataSource = $('#google-spreadsheet'),
      $visualization = $('#visualization'),
      $yAxis;
      // The Y-Axis will be lazily instantiated if needed.
  
  pullDataFromGoogleSpreadsheet($dataSource.val());
  
  $('button#regenerate').on('click', function () {
    $yAxis = $yAxis || $('#y-axis');
    $yAxis.html('');
    $visualization.html('');
    pullDataFromGoogleSpreadsheet($dataSource.val());
  })
  
  function pullDataFromGoogleSpreadsheet (url) {
    Tabletop.init( { key: url,
                     callback: generateGraph,
                     simpleSheet: true } );
  }
  
  function generateGraph (dataset, tabletop) {
    
    var keys = _.keys(dataset[0]),
        labels = {
          x: keys[0].charAt(0).toUpperCase() + keys[0].slice(1),
          y: keys[1].charAt(0).toUpperCase() + keys[1].slice(1),
        };
    
    dataset = _.map(dataset, function (data, key) {
                return {
                  x: parseInt(data[keys[0]], 10),
                  y: parseFloat(data[keys[1]], 10)
                };
              });
        
    var graph = new Rickshaw.Graph( {
      element: document.querySelector("#visualization"),
      width: 940,
      height: 250,
      series: [{
        color: '#00ADEF',
        stroke: 'rgba(0,0,0,0.15)',
        name: labels.y,
        data: dataset
      }]
    });
    
    graph.render();
    
    var hoverDetail = new Rickshaw.Graph.HoverDetail({
        graph: graph,
        xFormatter: function(x) { return labels.x + ": " + x },
        yFormatter: function(y) { return y }
    });
    
    var yAxis = new Rickshaw.Graph.Axis.Y({
        graph: graph,
        orientation: 'left',
        element: document.getElementById('y-axis')
    });
    
    var xAxis = new Rickshaw.Graph.Axis.X({
        graph: graph
    });
    
    yAxis.render();
    xAxis.render();
    
    var slider = new Rickshaw.Graph.RangeSlider({
        graph: graph,
        element: document.querySelector('#slider')
    });
    
  }
  
});