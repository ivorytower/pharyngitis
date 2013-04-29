$ = require "jquery"
_ = require "underscore"

{FileStatus} = require "../../file-status"
{execGitCommand} = require "../../git-command-executor"

selected = null
currentFileStatuses = null
cyclingGroups = false
selectionsForEachGroup = null
currentDir = null

class Selection
  constructor: (@group, @index) ->

  fileStatus: (fileStatuses = currentFileStatuses) ->
    fileStatuses[@group]?[@index]

  highlight: ->
    @__getElement().addClass "selected"

  clear: ->
    @__getElement().removeClass "selected"

  __getElement: ->
    $("##{@group}")?.find ".status-group:nth-of-type(#{@index + 1}) .file-container"

selectionByIndex = (indexCallback) ->
  selections = buildSelections currentFileStatuses
  index =
    # The "clever" code below implements cycling when iteration reaches top/bottom and also starting from top/bottom
    # when there's no current selection
    if selected?
      indexCallback(indexOf(selections, selected) + selections.length) % selections.length
    else
      indexCallback(selections.length) % (selections.length + 1)
  selections[index]

switchSelection = (selection) ->
  selected?.clear()
  selected = selection
  selected?.highlight()

buildSelections = (fileStatuses) ->
  fileStatuses = _.pairs(fileStatuses).map ([group, statuses]) ->
    [0...statuses.length].map (i) ->
      new Selection group, i
  [].concat fileStatuses...

indexOf = (array, element) ->
  for x, i in array
    if _.isEqual x, element
      return i
  -1

keyMap = {
  j: ->
    switchSelection selectionByIndex (index) ->
      index + 1

  k: ->
    switchSelection selectionByIndex (index) ->
      index - 1

  c: ->
    status = selected.fileStatus()
    unless status.untracked()
      execGitCommand currentDir, ["checkout", status.filename],
        ->
        ->
}

specialKeyMap = {
  "\t": ->
    if cyclingGroups
      selectionsForEachGroup.push selectionsForEachGroup.shift() unless selectionsForEachGroup.length == 0
    else
      selectionsForEachGroup = _.compact _.pairs(currentFileStatuses).map ([group, statuses]) ->
        new Selection group, 0 if statuses.length > 0

    switchSelection selectionsForEachGroup[0]
    cyclingGroups = true
}

$("body").keypress (event) ->
  handleKeyEvent(event, keyMap)

$("body").keyup (event) ->
  handleKeyEvent(event, specialKeyMap)

handleKeyEvent = (event, keyMap) ->
  key = String.fromCharCode event.which
  cyclingGroups = false unless key == "\t"
  keyMap[key]?()

@onUpdate = (fileStatuses, dir) ->
  fileStatuses = FileStatus.group fileStatuses
  previouslySelected = selected
  selected = null
  cyclingGroups = false
  currentDir = dir

  if previouslySelected?
    # If the same file status is present, select it
    previouslySelectedStatus = previouslySelected.fileStatus()
    selections = buildSelections(fileStatuses)
    orderedStatuses = selections.map (selection) ->
      selection.fileStatus fileStatuses
    indexInSelections = indexOf orderedStatuses, previouslySelectedStatus
    selected = selections[indexInSelections]

    # If not select the file status in the same staging group with the same index which would likely be the one that
    # was previously after it in the same group
    unless selected?
      groupSize = fileStatuses[previouslySelected.group].length
      if groupSize > 0
        selected = new Selection previouslySelected.group,
                                 if previouslySelected.index <= groupSize then previouslySelected.index else groupSize

  currentFileStatuses = fileStatuses
  selected?.highlight()

@getSelected = ->
  selected
