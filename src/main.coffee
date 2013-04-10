child_process = require "child_process"

$ = require "jquery"
fsmonitor = require "fsmonitor"
gui = require "nw.gui"

parser = require "./parser"
ui = require "./ui"

redisplay = (fileStatuses) ->
  ui.refresh(fileStatuses)

execGitStatus = (dir, callback, errorCallback) ->
  child_process.execFile(
    "/usr/bin/git"
    ["status", "--porcelain", "-z"]
    cwd: dir
    (error, stdout, stderr) ->
      unless error
        callback stdout.toString()
      else
        ui.displayError("Error executing git status: " + stderr.toString())
        errorCallback()
  )

refreshStatus = (dir, callback, errorCallback) ->
  execGitStatus(
    dir
    (output) ->
      redisplay parser.parse(output)
      callback()
    errorCallback
  )

fsWatchLoop = (dir) ->
  # TODO exclude git ignored files as well by asking git whether it ignores
  isInDotGit = (path) ->
    path.match /^.git\/(?!index$)/
  fileFilter =
    matches: (path) -> !isInDotGit(path)
    excludes: (path) -> isInDotGit(path)

  monitor = fsmonitor.watch dir, fileFilter, (_) =>
    refreshStatus(
      dir
      ->
      ->
        monitor.close()
    )

$ ->
  dir = gui.App.argv[0]
  refreshStatus(
    dir
    ->
      fsWatchLoop dir
    ->
  )
