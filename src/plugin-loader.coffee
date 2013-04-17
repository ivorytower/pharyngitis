fs = require "fs"

# module_loader is a dependency injection needed for the tests
@load = (module_loader = require) ->
  dirs = fs.readdirSync("plugins").filter (dir) ->
    fs.statSync("plugins/" + dir).isDirectory()
  dirs.map (dir) ->
    dir = "plugins/#{dir}/"

    main_js_file = dir + "main.js"
    main = module_loader("./" + main_js_file[0...-3]) if fs.existsSync(main_js_file)
    onUpdate = main.onUpdate if main

    css_file = dir + "style.css"
    {
      onUpdate: onUpdate
      css_file: if fs.existsSync(css_file) then css_file else undefined
    }
