groupByFileStatus = (require "./file-status").FileStatus.group

fs = require "fs"

$ = require "jquery"
jade = require "jade"

@refresh = (fileStatuses, branch) ->
  filename = "templates/file-list.jade"
  template = jade.compile fs.readFileSync(filename, "utf8"), filename: filename

  $("#page").html template(groupByFileStatus fileStatuses)
  $("title").text branch

@displayError = (message) ->
  $("#page").empty().append $("<div class=\"error-message\" />").text message
