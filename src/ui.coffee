fs = require "fs"

$ = require "jquery"
jade = require "jade"

template = jade.compile fs.readFileSync("templates/file-list.jade", "utf8")

@refresh = (fileStatuses) ->
  $("#page").html template(fileStatuses: fileStatuses)
