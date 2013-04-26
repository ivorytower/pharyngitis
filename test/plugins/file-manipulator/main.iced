mockit = require "mockit"
sinon = require "sinon"
_ = require "underscore"

onKeypress = null
# This brilliant piece of engineering allows calling and chaining any jQuery methods and requires only listing their
# names
jqueryStub = sinon.stub()
jqueryStub.returns _.object(["find", "addClass", "removeClass"].map (method) ->
  [method, jqueryStub])

jqueryStub.withArgs("body").returns {
  keypress: (callback) ->
    onKeypress = callback
}

{onUpdate, getSelected} = mockit "../../../src/plugins/file-manipulator/main", {
  jquery: jqueryStub
}

{FileStatus} = require "../../../src/file-status"

should = require "should"

describe "file manipulator", ->
  describe "selected", ->
    assertSelected = (expected) ->
      _.values(getSelected()).should.eql expected

    press = (key) ->
      onKeypress {which: key.charCodeAt()}

    it "selects nothing by default", ->
      onUpdate [
        new FileStatus "M", " ", "file"
      ]
      should.not.exist getSelected()

    it "goes to the first file when j is pressed", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
      ]
      press "j"
      assertSelected ["staged", 0]

    it "goes to the last file when k is pressed", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
      ]
      press "k"
      assertSelected ["staged", 1]

    it "iterates up and down on consecutive presses", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
      ]
      press "j"
      press "j"
      assertSelected ["staged", 1]

      onUpdate [
        new FileStatus "M", " ", "file3"
        new FileStatus "M", " ", "file4"
      ]
      press "k"
      press "k"
      assertSelected ["staged", 0]

      onUpdate [
        new FileStatus "M", " ", "file5"
        new FileStatus "M", " ", "file6"
      ]
      press "j"
      press "j"
      press "k"
      assertSelected ["staged", 0]

    it "cycles through the top/bottom of the list", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
      ]
      press "j"
      press "j"
      press "j"
      assertSelected ["staged", 0]
      press "k"
      assertSelected ["staged", 1]

    it "stays on in when there's only one file", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
      ]
      press "j"
      press "j"
      assertSelected ["staged", 0]
      press "k"
      press "k"
      assertSelected ["staged", 0]

    it "doesn't break when there are no files", ->
      onUpdate []
      press "j"
      press "j"
      press "j"
      press "k"
      should.not.exist getSelected()
