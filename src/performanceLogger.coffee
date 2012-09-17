fs = require('fs')
class PerformanceLogger
    logStream = null
    loggingTimeoutId = null
    startMilliSecond = 0

    constructor: (@logFileName) ->
    
    start: ->
        logStream = fs.createWriteStream(@logFileName)
         # we use timeout and not interval because we do not want to count
         # the time used for writing to the log file itself

        loggingTimeoutId = setInterval(@writeToLogFile, 1000)
        logStream.write(@getHeader())
        startMilliSecond = Date.now()
    
    # We use the fat arrow => so that we have the context preserved for the timer call
    writeToLogFile: () =>
        logStream.write(@getNextLogString())
    
    writeAverageStatistics: ->
        milliSecondsNow = Date.now()
        durationOfPerformanceTest = (milliSecondsNow - startMilliSecond) /  1000
        averageFileStream = fs.createWriteStream(@logFileName + ".average")
        averageFileStream.write(@getAverageHeader())
        averageFileStream.write(@getAverageString(durationOfPerformanceTest))
        averageFileStream.end()

    close: ->
        clearInterval(loggingTimeoutId)
        logStream.end()

exports.PerformanceLogger = PerformanceLogger
    