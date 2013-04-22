childProcess = require "child_process"

$ = require "jquery"
fsmonitor = require "fsmonitor"
gui = require "nw.gui"

parser = require "./parser"
ui = require "./ui"
pluginLoader = require "./plugin-loader"

redisplay = (fileStatuses, branch) ->
  ui.refresh fileStatuses, branch

execGitCommand = (dir, args, callback, errorCallback) ->
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

refreshStatus = (dir, callback, errorCallback) ->
  await
    execGitCommand(
      dir
      ["status", "--porcelain", "-z"]
      defer output
      errorCallback
    )
    execGitCommand(
      dir
      ["rev-parse", "--abbrev-ref", "HEAD"]
      defer branch
      errorCallback
    )

  redisplay parser.parse(output), branch
  callback()

fsWatchLoop = (dir, callback) ->
  # TODO exclude git ignored files as well by asking git whether it ignores
  isInDotGit = (path) ->
    path.match /^.git\/(?!index$)/
  fileFilter =
    matches: (path) -> !isInDotGit(path)
    excludes: (path) -> isInDotGit(path)

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
      ->
        for plugin in plugins
          plugin.onUpdate?()
        callback()
      errorCallback
    )
  refresh(
    ->
      fsWatchLoop dir, refresh
    ->
  )
