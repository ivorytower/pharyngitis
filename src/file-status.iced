class @FileStatus
  constructor: (@firstColumn, @secondColumn, @filename, @oldFilename = null) ->

  staged: ->
    @firstColumn != " " && !@untracked()

  unstaged: ->
    @secondColumn != " " && !@untracked()

  untracked: ->
    @firstColumn == "?"

  added: ->
    @firstColumn == "A"

  deleted: ->
    @firstColumn == "D" || @secondColumn == "D"

  @group: (fileStatuses) ->
    {
      staged: fileStatuses.filter (f) -> f.staged()
      unstaged: fileStatuses.filter (f) -> f.unstaged()
      untracked: fileStatuses.filter (f) -> f.untracked()
    }
