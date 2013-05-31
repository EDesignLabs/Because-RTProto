require ["d3.v3.min","ui","visualization"], (d3, ui, visualization) ->
    $(document).ready ->
        ui.startRealtime ui.rtclient
