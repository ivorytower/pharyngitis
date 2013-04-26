{FileStatus} = require "../../file-status"

$ = require "jquery"
_ = require "underscore"

class Selection
  constructor: (@group, @index) ->

  highlight: ->
    @__getElement().addClass "selected"

  clear: ->
    @__getElement().removeClass "selected"

  __getElement: ->
    $("##{@group}")?.find ".status-group:nth-of-type(#{@index + 1}) .file-container"

selected = null
statuses = null

switchSelection = (newSelectionF) ->
  selected?.clear()

  selections = buildSelections statuses
  index =
    # The "clever" code below implements cycling when iteration reaches top/bottom and also starting from top/bottom
    # when there's no current selection
    if selected?
      newSelectionF(indexOf(selections, selected) + selections.length) % selections.length
    else
      newSelectionF(selections.length) % (selections.length + 1)
  selected = selections[index]

  selected?.highlight()

buildSelections = (statuses) ->
  statuses = _.pairs(FileStatus.group statuses).map ([group, statuses]) ->
    [0...statuses.length].map (i) ->
      new Selection group, i
  [].concat statuses...

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
  statuses = fileStatuses
  selected = null

@getSelected = ->
  selected
