{FileStatus} = require "../../file-status"

$ = require "jquery"
_ = require "underscore"

selected = null
currentFileStatuses = null

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

switchSelection = (newSelectionF) ->
  selected?.clear()

  selections = buildSelections currentFileStatuses
  index =
    # The "clever" code below implements cycling when iteration reaches top/bottom and also starting from top/bottom
    # when there's no current selection
    if selected?
      newSelectionF(indexOf(selections, selected) + selections.length) % selections.length
    else
      newSelectionF(selections.length) % (selections.length + 1)
  selected = selections[index]

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
    switchSelection (index) ->
      index + 1

  k: ->
    switchSelection (index) ->
      index - 1
}

$("body").keypress (event) ->
  keyMap[String.fromCharCode event.which]?()

@onUpdate = (fileStatuses) ->
  fileStatuses = FileStatus.group fileStatuses
  previouslySelected = selected
  selected = null

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

@getSelected = ->
  selected
