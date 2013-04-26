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

{FileStatus} = require "../../../src/file-status"

{onUpdate, getSelected} = mockit "../../../src/plugins/file-manipulator/main", {
  jquery: jqueryStub
}

should = require "should"

describe "file manipulator", ->
  describe "selected", ->
    # This is to clear any previously selected file
    beforeEach ->
      onUpdate []

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
        new FileStatus "M", " ", "file3"
      ]
      press "j"
      press "j"
      press "j"
      assertSelected ["staged", 2]

      press "k"
      press "k"
      assertSelected ["staged", 0]

      press "j"
      press "j"
      press "k"
      assertSelected ["staged", 1]

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

    it "remembers the selected file when a file disappears", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
        new FileStatus " ", "M", "file3"
      ]
      press "j"
      press "j"
      onUpdate [
        new FileStatus "M", " ", "file2"
        new FileStatus " ", "M", "file3"
      ]
      assertSelected ["staged", 0]

    it "remembers the selected file when a new file appears", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus " ", "M", "file3"
      ]
      press "k"
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
        new FileStatus " ", "M", "file3"
      ]
      assertSelected ["unstaged", 0]

    it "selects the next file in the group when the file has disappeared", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
        new FileStatus "M", " ", "file3"
        new FileStatus " ", "M", "file4"
      ]
      press "j"
      press "j"
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file3"
        new FileStatus " ", "M", "file4"
      ]
      assertSelected ["staged", 1]

    it "clears the selection when the selected sole file in a group disappears", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus " ", "M", "file2"
      ]
      press "j"
      onUpdate [
        new FileStatus " ", "M", "file2"
      ]
      should.not.exist getSelected()
