fs = require "fs"

# moduleLoader is a dependency injection needed for the tests
@load = (moduleLoader = require) ->
  dirs = fs.readdirSync("plugins").filter (dir) ->
    fs.statSync("plugins/" + dir).isDirectory()
  dirs.map (dir) ->
    dir = "plugins/#{dir}/"

    mainJsFile = dir + "main.js"
    main = moduleLoader("./" + mainJsFile[0...-3]) if fs.existsSync(mainJsFile)
    onUpdate = main?.onUpdate

    cssFile = dir + "style.css"
    {
      onUpdate: onUpdate
      cssFile: if fs.existsSync(cssFile) then cssFile else undefined
    }
