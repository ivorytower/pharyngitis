childProcess = require "child_process"

ui = require "./ui"

@execGitCommand = (dir, args, callback, errorCallback) ->
  childProcess.execFile(
    "/usr/bin/git"
    args
    cwd: dir
    (error, stdout, stderr) ->
      unless error?
        callback stdout.toString()
      else
        ui.displayError("Error executing git #{args[0]}: #{stderr.toString()}")
        errorCallback()
  )
