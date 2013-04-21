{FileStatus} = parser = require "../src/parser"
should = require "should"

describe "Parser", ->
  parse = (input) ->
    parser.parse input

  describe "#parse()", ->
    it "should work when there are no changes", ->
      parse("").should.be.empty

    it "should give the first status char", ->
      parse("AM file\0")[0].firstColumn.should.equal "A"

    it "should give the second status char", ->
      parse("AM file\0")[0].secondColumn.should.equal "M"

    it "should give the filename", ->
      parse("AM file\0")[0].filename.should.equal "file"

    it "should give the old filename as well", ->
      parse("R  file\0old-file\0")[0].filename.should.equal "file"
      parse("R  file\0old-file\0")[0].oldFilename.should.equal "old-file"

    it "should not give the old filename when there is none", ->
      should.not.exist parse("A  file\0")[0].oldFilename

    it "should give the status char when it's blank", ->
      parse(" M file\0")[0].firstColumn.should.equal " "
      parse("A  file\0")[0].secondColumn.should.equal " "

    it "should give the file name when it contains special characters", ->
      parse(" M ab c\0")[0].filename.should.equal "ab c"
      parse(" M ab\nc\0")[0].filename.should.equal "ab\nc"

    it "should work when there is more than one file changed", ->
      parse("?? file1\0M  file2\0")[1].filename.should.equal "file2"
      parse("R  file1\0file1-old\0M  file2\0")[1].filename.should.equal "file2"

  describe "FileStatus", ->
    it "tells if the file is staged", ->
      (new FileStatus "M", " ", "file").staged().should.be.ok
      (new FileStatus " ", "M", "file").staged().should.not.be.ok
