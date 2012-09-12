fs = require('fs')
util = require('util')
numToStrWithLength =  require('./utilities').numToStrWithLength

class InsertionLogger
  logStream = null
  numberOfCharsAtLastTick = 0
  numberOfChars = 0
  numberOfInsertionsAtLastTick = 0
  numberOfInsertions = 0
  loggingTimeoutId = null
 
  constructor: (@logFileName) ->
      
  start: ->
     logStream = fs.createWriteStream(@logFileName)
     # we use timeout and not interval because we do not want to count
     # the time used for writing to the log file itself
     loggingTimeoutId = setTimeout(writeToLogFile, 1000)
     logStream.write('Second   \tCharacters\tInserts\tTotalChars\tTotalInserts\n')
      
  logInsertion: (numberOfCharacters) ->
      numberOfChars += numberOfCharacters
      numberOfInsertions++

  writeToLogFile = ->
      console.log('writing to log file')
      numberOfCharsThisSecond = numberOfChars - numberOfCharsAtLastTick
      numberOfInsertionsThisSecond = numberOfInsertions - numberOfInsertionsAtLastTick
      logStream.write(
          util.format('%d \t %d  \t %d \t %d \t %d'
                       numToStrWithLength(Date.now() / 1000, 10)
                       numToStrWithLength(numberOfCharsThisSecond, 10)
                       numToStrWithLength(numberOfInsertionsThisSecond, 10)
                       numToStrWithLength(numberOfChars, 10)
                       numToStrWithLength(numberOfInsertions, 10)
                      ))
        
      logStream.write('\n')
      numberOfCharsAtLastTick = numberOfChars
      numberOfInsertionsAtLastTick = numberOfInsertions
      loggingTimeoutId = setTimeout(writeToLogFile, 1000)

  close: ->
      clearTimeout(loggingTimeoutId)
      logStream.end()

exports.InsertionLogger = InsertionLogger