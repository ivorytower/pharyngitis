fs = require "fs"

$ = require "jquery"
jade = require "jade"

@refresh = (fileStatuses, branch) ->
  filename = "templates/file-list.jade"
  template = jade.compile fs.readFileSync(filename, "utf8"), filename: filename

  locals =
    staged: fileStatuses.filter (f) -> f.staged()
    unstaged: fileStatuses.filter (f) -> f.unstaged()
    untracked: fileStatuses.filter (f) -> f.untracked()
  $("#page").html template(locals)
  $("title").html branch

@displayError = (message) ->
  $("#page").html "<div class=\"error-message\">#{message}</div>"
