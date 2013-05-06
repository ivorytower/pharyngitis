mockit = require "mockit"
sinon = require "sinon"
_ = require "underscore"

onKeypress = null
onKeyup = null
# This brilliant piece of engineering allows calling and chaining any jQuery methods and requires only listing their
# names
jqueryStub = sinon.stub()
jqueryStub.returns _.object(["find", "addClass", "removeClass"].map (method) ->
  [method, jqueryStub])

jqueryStub.withArgs("#page").returns {
  keypress: (callback) ->
    onKeypress = callback
  keyup: (callback) ->
    onKeyup = callback
  focus: ->
}

gitExecSucceeds = true
# This absolute nonsense is necessitated by the way Sinon works
spiable = {
  gitExecImpl: (dir, command, callback, errorCallback) ->
    if gitExecSucceeds
      callback()
    else
      errorCallback()
}

gitExec = (dir, args, callback, errorCallback) ->
  spiable.gitExecImpl(dir, args, callback, errorCallback)

{FileStatus} = require "../../../src/file-status"

{onUpdate, getSelected} = mockit "../../../src/plugins/file-manipulator/main", {
  jquery: jqueryStub
  "../../git-command-executor": {execGitCommand: gitExec}
}

should = require "should"

describe "file manipulator", ->
  press = (key) ->
    f = if ["\t"].indexOf(key) >= 0 then onKeyup else onKeypress
    f {which: key.charCodeAt()}

  # This is to clear any previously selected file
  beforeEach ->
    onUpdate []

  describe "#getSelected()", ->
    assertSelected = (expected) ->
      _.values(getSelected()).should.eql expected

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

    it "remembers the selected file when it is present in both staged and unstaged groups", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", "M", "file2"
      ]
      press "k"
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", "M", "file2"
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

    # Cycling should always start from the first group and when anything but <tab> is pressed it should stop
    it "cycles between the first files in each group when <tab> is pressed", ->
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", " ", "file2"
        new FileStatus "?", "?", "file3"
        new FileStatus "?", "?", "file4"
      ]
      press "\t"
      assertSelected ["staged", 0]

      press "\t"
      assertSelected ["untracked", 0]

      press "\t"
      assertSelected ["staged", 0]

      press "j"
      press "\t"
      assertSelected ["staged", 0]

      press "j"
      press "j"
      press "j"
      press "\t"
      press "\t"
      assertSelected ["untracked", 0]

      press "\t"
      onUpdate [
        new FileStatus "M", " ", "file1"
        new FileStatus "M", "M", "file2"
        new FileStatus "?", "?", "file3"
        new FileStatus "?", "?", "file4"
      ]
      press "\t"
      assertSelected ["staged", 0]

  describe "executing commands on files", ->
    dir = sinon.spy()
    gitExecSpy = null

    selectFile = (status) ->
      onUpdate [new FileStatus status...], dir
      press "j"

    beforeEach ->
      gitExecSucceeds = true
      gitExecSpy = sinon.spy spiable, "gitExecImpl"

    afterEach ->
      spiable.gitExecImpl.restore()

    it "executes git checkout when c is pressed", ->
      selectFile [" ", "M", "file"]
      press "c"
      gitExecSpy.calledWith(dir, "checkout file").should.be.ok

    it "calls git checkout with the proper file name when a file was moved", ->
      selectFile [" ", "M", "file", "oldFile"]
      press "c"
      gitExecSpy.calledWith(dir, "checkout file").should.be.ok

    it "doesn't execute git checkout on staged or untracked files", ->
      selectFile ["?", "?", "file"]
      press "c"
      gitExecSpy.callCount.should.equal 0
      selectFile ["M", " ", "file"]
      press "c"
      gitExecSpy.callCount.should.equal 0

    it "executes git add when s is pressed on an untracked file", ->
      selectFile ["?", "?", "file"]
      press "s"
      gitExecSpy.calledWith(dir, "add file").should.be.ok

    it "executes git add when s is pressed on an unstaged file", ->
      selectFile [" ", "M", "file"]
      press "s"
      gitExecSpy.calledWith(dir, "add file").should.be.ok

    it "executes git reset when s is pressed on a staged file", ->
      selectFile ["M", " ", "file"]
      press "s"
      gitExecSpy.calledWith(dir, "reset -- file").should.be.ok

    it "executes git add or reset based on where the file was selected for files that are both staged and unstaged", ->
      onUpdate [new FileStatus("M", "M", "file")], dir
      press "j"
      press "s"
      gitExecSpy.calledWith(dir, "reset -- file").should.be.ok
      press "j"
      press "s"
      gitExecSpy.secondCall.calledWith(dir, "add file").should.be.ok

    it "executes git difftool -y when d is pressed on an unstaged file", ->
      selectFile [" ", "M", "file"]
      press "d"
      gitExecSpy.calledWith(dir, "difftool -y file").should.be.ok

    it "executes git difftool -y --cached when d is pressed on a staged file", ->
      selectFile ["M", " ", "file"]
      press "d"
      gitExecSpy.calledWith(dir, "difftool -y --cached file").should.be.ok

    it "doesn't execute anything if no file is selected", ->
      onUpdate [new FileStatus("M", " ", "file")], dir
      press "c"
      press "s"
      press "d"
      gitExecSpy.callCount.should.equal 0
