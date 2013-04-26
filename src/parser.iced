{FileStatus} = require "./file-status"

@parse = (input) =>
  filenameRegexp = "([^\\0]+)\\0"
  statusLineRegexp = ///
    (
      ([RC])(.)\s   # status for renamed or copied in index
      #{filenameRegexp}  # filename
      #{filenameRegexp}  # old filename
    )
    |
    (
      (.)(.)\s  # status, also titties :P
      #{filenameRegexp}  # filename
    )
  ///g

  while match = statusLineRegexp.exec(input)
    statusLineMatches = if match[1]? then match[2..5] else match[7..9]
    new FileStatus statusLineMatches...
