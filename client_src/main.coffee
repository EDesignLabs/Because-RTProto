require ["vendor/d3.v3.min","ui","visualization"], (d3, ui, visualization) ->
    $(document).ready ->
        Visualization.initialize -> ui.startRealtime ui.rtclient