$ = require "jquery"

{execGitCommand} = require "../../git-command-executor"

currentDir = null

$("#footer").prepend $("<div id=\"command-executor\">
  <input type=text id=\"command-line\">
  <textarea id=\"output\" readonly=\"true\"/>
  </div>")

hideExecutor = ->
  $("#command-executor").hide()
  $("#command-line").val ""
  $("#output").val ""
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

displayOutput = (output) ->
  $("#output").val(output)

displayError = (errorMessage, command) ->
  $("#output").val("Error executing git #{command}: #{errorMessage}")

$("#command-line").keyup (event) ->
  key = String.fromCharCode event.which
  if key == "\r"
    command = $("#command-line").val().trim()
    $("#command-line").val ""
    if command != ""
      execGitCommand(
        currentDir
        command
        displayOutput
        displayError
      )

@onUpdate = (fileStatuses, dir) ->
  currentDir = dir
  $("#command-line:visible").focus()
