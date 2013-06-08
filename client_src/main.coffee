require ["vendor/d3.v3.min","ui","visualization"], (d3, ui, Visualization) ->
    $(document).ready ->
        Visualization.initialize -> ui.startRealtime ui.rtclient