require ["ui", "visualization"], (ui, Visualization) ->
    $(document).ready ->
        Visualization.initialize -> ui.startRealtime ui.rtclient
