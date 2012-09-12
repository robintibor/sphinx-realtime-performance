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
  startMilliSecond = 0
 
  constructor: (@logFileName) ->
      
  start: ->
     logStream = fs.createWriteStream(@logFileName)
     # we use timeout and not interval because we do not want to count
     # the time used for writing to the log file itself
     loggingTimeoutId = setInterval(writeToLogFile, 1000)
     logStream.write('#Second   \tCharacters\tInserts\tTotalChars\tTotalInserts\n')
     startMilliSecond = Date.now()
      
  logInsertion: (numberOfCharacters) ->
      numberOfChars += numberOfCharacters
      numberOfInsertions++

  writeToLogFile = ->
      numberOfCharsThisSecond = numberOfChars - numberOfCharsAtLastTick
      numberOfInsertionsThisSecond = numberOfInsertions - numberOfInsertionsAtLastTick
      logStream.write(
          util.format('%s \t %s  \t %s \t %s \t %s'
                       numToStrWithLength(Date.now() / 1000, 10)
                       numToStrWithLength(numberOfCharsThisSecond, 10)
                       numToStrWithLength(numberOfInsertionsThisSecond, 5)
                       numToStrWithLength(numberOfChars, 10)
                       numToStrWithLength(numberOfInsertions, 10)
                      ))
        
      logStream.write('\n')
      numberOfCharsAtLastTick = numberOfChars
      numberOfInsertionsAtLastTick = numberOfInsertions

    writeAverageStatistics: ->
        milliSecondsNow = Date.now()
        durationOfPerformanceTest = (milliSecondsNow - startMilliSecond) /  1000
        averageNumberOfChars = Math.floor(numberOfChars / durationOfPerformanceTest)
        averageNumberOfInsertions = Math.floor(numberOfInsertions / durationOfPerformanceTest)
        averageFileStream = fs.createWriteStream(@logFileName + ".average")
        averageFileStream.write("Chars/sec\t Inserts/sec\n")
        averageFileStream.write(util.format('%s    \t %s\n', averageNumberOfChars, averageNumberOfInsertions))
        averageFileStream.end()

  close: ->
      clearInterval(loggingTimeoutId)
      logStream.end()

exports.InsertionLogger = InsertionLogger