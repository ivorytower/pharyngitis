$ = require "jquery"

@onUpdate = (fileStatuses) ->
  $("#page").append $("<div id=\"last-updated-at\"></div>").text "Last updated at #{(new Date).toLocaleTimeString()}"
