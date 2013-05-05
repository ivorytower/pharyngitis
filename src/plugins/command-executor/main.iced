$ = require "jquery"

{execGitCommand} = require "../../git-command-executor"

$("#footer").prepend $("<div id=\"command-executor\">
  <input type=text id=\"command-line\">
  <textarea id=\"output\" readonly=\"true\"/>
  </div>")

hideExecutor = ->
  $("#command-executor").hide()
  $("#command-line").val ""
  $("#page").focus()

hideExecutor()

showExecutor = ->
  $("#command-executor").show()
  $("#command-line").focus()

$("body").keyup (event) ->
  key = String.fromCharCode event.which
  if key == " "
    showExecutor()
  else if key == "\x1b" ||
          (key == "D" && event.ctrlKey)
    hideExecutor()

@onUpdate = (fileStatuses, dir) ->
