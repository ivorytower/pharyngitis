{FileStatus} = require "../src/file-status"

describe "FileStatus", ->
  it "tells if the file is staged", ->
    (new FileStatus "M", " ", "file").staged().should.be.ok
    (new FileStatus " ", "M", "file").staged().should.not.be.ok
