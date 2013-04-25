pluginLoader = require "../src/plugin-loader"

should = require "should"
sinon = require "sinon"
FakeFS = require "fake-fs"

describe "Plugin Loader", ->
  fs = null

  beforeEach ->
    fs = new FakeFS
    fs.patch()

  afterEach ->
    fs.unpatch()

  loadPlugins = (files) ->
    moduleLoader = sinon.stub()
    for file in files
      filePath = "plugins/" + file.name
      fs.file filePath, ""
      if filePath[-3..] == ".js"
        moduleLoader.withArgs("./" + filePath[0...-3]).returns { onUpdate: file.onUpdate }

    pluginLoader.load(moduleLoader)

  describe "#load()", ->
    it "should provide JS callback", ->
      loadPlugins([
        {
          name: "p1/main.js"
          onUpdate: -> "expected"
        }
      ])[0].onUpdate().should.equal "expected"

    it "should provide CSS file", ->
      loadPlugins([
        {
          name: "p1/style.css"
        }
      ])[0].cssFile.should.equal "plugins/p1/style.css"

    it "should work for more than one plugin", ->
      loadPlugins([
        {
          name: "p1/main.js"
          onUpdate: -> "unexpected"
        }
        {
          name: "p2/main.js"
          onUpdate: -> "expected"
        }
      ])[1].onUpdate().should.equal "expected"

    # TODO load plugins in alphabetical order

    it "should set JS callback and CSS to undefined if not provided", ->
      plugin = loadPlugins([
        {
          name: "p1/support.js"
        }
      ])[0]
      should.not.exist plugin.onUpdate
      should.not.exist plugin.cssFile
