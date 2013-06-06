require ["d3.v3.min","ui"], (d3, ui) ->
    $(document).ready ->
        ui.startRealtime ui.rtclient
