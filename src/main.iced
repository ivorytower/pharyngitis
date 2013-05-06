$ = require "jquery"
fsmonitor = require "fsmonitor"
gui = require "nw.gui"

parser = require "./parser"
{execGitCommand} = require "./git-command-executor"
ui = require "./ui"
pluginLoader = require "./plugin-loader"

redisplay = (fileStatuses, branch) ->
  ui.refresh fileStatuses, branch

refreshStatus = (dir, callback, errorCallback) ->
  errorCb = (errorMessage, command) ->
    ui.displayError("Error executing git #{command}: #{errorMessage}")
    errorCallback()

  await
    execGitCommand(
      dir
      "status --porcelain -z"
      defer output
      errorCb
    )
    execGitCommand(
      dir
      "rev-parse --abbrev-ref HEAD"
      defer branch
      errorCb
    )

  fileStatuses = parser.parse(output)
  redisplay fileStatuses, branch
  callback fileStatuses

fsWatchLoop = (dir, callback) ->
  # TODO exclude git ignored files as well by asking git whether it ignores
  fileFilter =
    matches: (_) -> true
    excludes: (path) ->
      path.match /^.git\//

  monitor = fsmonitor.watch dir, fileFilter, (_) ->
    callback(
      ->
      ->
        monitor.close()
    )

$ ->
  dir = gui.App.argv[0]

  plugins = pluginLoader.load()
  for plugin in plugins
    $("head").append $("<link rel=\"stylesheet\">").attr("href", plugin.cssFile) if plugin.cssFile

  refresh = (callback, errorCallback) ->
    refreshStatus(
      dir
      (fileStatuses) ->
        for plugin in plugins
          plugin.onUpdate? fileStatuses, dir
        callback()
      errorCallback
    )
  refresh(
    ->
      fsWatchLoop dir, refresh
    ->
  )
