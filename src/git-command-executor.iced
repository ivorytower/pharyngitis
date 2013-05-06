childProcess = require "child_process"

ui = require "./ui"

@execGitCommand = (dir, command, callback, errorCallback) ->
  childProcess.exec(
    "/usr/bin/git " + command
    {
      cwd: dir
      stdio: ["ignore"]
    }
    (error, stdout, stderr) ->
      unless error?
        callback stdout.toString()
      else
        errorCallback(stderr.toString(), command)
  )
