plugin_loader = require "../src/plugin-loader"

should = require "should"
sinon = require "sinon"
mockit = require "mockit"
FakeFS = require "fake-fs"

describe "Plugin Loader", ->
  fs = null

  beforeEach ->
    fs = new FakeFS
    fs.patch()

  afterEach ->
    fs.unpatch()

  load_plugins = (files) ->
    module_loader = sinon.stub()
    for file in files
      filePath = "plugins/" + file.name
      fs.file filePath, ""
      if filePath[-3..] == ".js"
        module_loader.withArgs("./" + filePath[0...-3]).returns { onUpdate: file.onUpdate }

    plugin_loader.load(module_loader)

  describe "#load()", ->
    it "should provide JS callback", ->
      load_plugins([
        {
          name: "p1/main.js"
          onUpdate: -> "expected"
        }
      ])[0].onUpdate().should.equal "expected"

    it "should provide CSS file", ->
      load_plugins([
        {
          name: "p1/style.css"
        }
      ])[0].css_file.should.equal "plugins/p1/style.css"

    it "should work for more than one plugin", ->
      load_plugins([
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
      plugin = load_plugins([
        {
          name: "p1/support.js"
        }
      ])[0]
      should.not.exist plugin.onUpdate
      should.not.exist plugin.css_file
