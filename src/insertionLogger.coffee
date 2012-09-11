fs = require("fs")

class InsertionLogger
  logStream = null
  numberOfCharsAtLastTick = 0
  numberOfChars = 0
  loggingTimeoutId = null
 
  constructor: (@logFileName) ->
    
  start: ->
     logStream = fs.createWriteStream(@logFileName)
     # we use timeout and not interval because we do not want to count
     # the time used for writing to the log file itself
     loggingTimeoutId = setTimeout(writeToLogFile, 1000)
      
  logInsertion: (numberOfCharacters) ->
      numberOfChars += numberOfCharacters

  writeToLogFile = ->
      numberOfCharsThisSecond = numberOfChars - numberOfCharsAtLastTick
      logStream.write(numberOfChars  + '\t' + numberOfCharsThisSecond)
      logStream.write('\n')
      numberOfCharsAtLastTick = numberOfChars
      loggingTimeoutId = setTimeout(writeToLogFile, 1000)

  close: ->
      clearTimeout(loggingTimeoutId)
      logStream.end()

exports.InsertionLogger = InsertionLogger