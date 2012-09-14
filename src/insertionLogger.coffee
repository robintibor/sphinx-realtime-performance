fs = require('fs')
util = require('util')
numToStrWithLength =  require('./utilities').numToStrWithLength

class InsertionLogger
    logStream = null
      
    numberOfCharsAtLastTick = 0
    numberOfInsertionsAtLastTick = 0
    numberOfReplacementsAtLastTick = 0
    numberOfReplacedCharsAtLastTick = 0
    numberOfChars = 0
    numberOfInsertions = 0
    numberOfReplacements = 0
    numberOfReplacedChars = 0
    
    loggingTimeoutId = null
    startMilliSecond = 0
    nrOfTopics = 0
    
    constructor: (@logFileName) ->
      
    start: ->
         logStream = fs.createWriteStream(@logFileName)
         # we use timeout and not interval because we do not want to count
         # the time used for writing to the log file itself
         loggingTimeoutId = setInterval(writeToLogFile, 1000)
         logStream.write('#Second   \tCharacters\tInserts\tReplacedChars\tReplaces\tTotalChars\tTotalInserts\tTotalTopics\n')
         startMilliSecond = Date.now()
      
    logInsertion: (numberOfCharacters, newTopic) ->
        numberOfChars += numberOfCharacters
        numberOfInsertions++
        if (newTopic)
            nrOfTopics++
    
    logReplacement: (numberOfCharacters) ->
        numberOfReplacedChars += numberOfCharacters
        numberOfReplacements++
    
    writeToLogFile = ->
        numberOfCharsThisSecond = numberOfChars - numberOfCharsAtLastTick
        numberOfInsertionsThisSecond = numberOfInsertions - numberOfInsertionsAtLastTick
        numOfReplacedCharsThisSec = numberOfReplacedChars - numberOfReplacedCharsAtLastTick
        numOfReplacementsThisSec = numberOfReplacements - numberOfReplacementsAtLastTick

        logStream.write(
            util.format('%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s'
                       numToStrWithLength((Date.now() % 100000000) / 1000, 10)
                       numToStrWithLength(numberOfCharsThisSecond, 10)
                       numToStrWithLength(numberOfInsertionsThisSecond, 5)
                       numToStrWithLength(numOfReplacedCharsThisSec, 10)
                       numToStrWithLength(numOfReplacementsThisSec, 5)
                       numToStrWithLength(numberOfChars, 10)
                       numToStrWithLength(numberOfInsertions, 10)
                       numToStrWithLength(nrOfTopics, 5)
                       ))
        
        logStream.write('\n')
        numberOfCharsAtLastTick = numberOfChars
        numberOfInsertionsAtLastTick = numberOfInsertions
        numberOfReplacementsAtLastTick = numberOfReplacements
        numberOfReplacedCharsAtLastTick = numberOfReplacedChars

    writeAverageStatistics: ->
        milliSecondsNow = Date.now()
        durationOfPerformanceTest = (milliSecondsNow - startMilliSecond) /  1000
        averageNumberOfChars = Math.floor(numberOfChars / durationOfPerformanceTest)
        averageNumberOfInsertions = Math.floor(numberOfInsertions / durationOfPerformanceTest)
        averageNumberOfReplacedChars = Math.floor(numberOfReplacedChars / durationOfPerformanceTest)
        averageNumberOfReplaces= Math.floor(numberOfReplacements / durationOfPerformanceTest)
        averageFileStream = fs.createWriteStream(@logFileName + ".average")
        averageFileStream.write("# (per sec) Chars\tInserts \tReplacedChars \tReplacements\n")
        averageFileStream.write(util.format('     %s    \t%s      \t%s \t%s\n',
                                            numToStrWithLength(averageNumberOfChars, 10)
                                            numToStrWithLength(averageNumberOfInsertions, 5)
                                            numToStrWithLength(averageNumberOfReplacedChars, 10)
                                            numToStrWithLength(averageNumberOfReplaces, 5)
                                            ))
        averageFileStream.end()

    close: ->
        clearInterval(loggingTimeoutId)
        logStream.end()

exports.InsertionLogger = InsertionLogger