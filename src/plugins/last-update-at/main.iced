$ = require "jquery"

$("#footer").append $("<div id=\"last-updated-at\"></div>")

@onUpdate = (fileStatuses, dir) ->
  $("#last-updated-at").text "Last updated at #{(new Date).toLocaleTimeString()}"
