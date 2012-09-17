fs = require('fs')
util = require('util')
numToStrWithLength =  require('./utilities').numToStrWithLength
PerformanceLogger = require('./performanceLogger.js').PerformanceLogger

class InsertionLogger extends PerformanceLogger
      
    numberOfCharsAtLastTick = 0
    numberOfInsertionsAtLastTick = 0
    numberOfReplacementsAtLastTick = 0
    numberOfReplacedCharsAtLastTick = 0
    numberOfChars = 0
    numberOfInsertions = 0
    numberOfReplacements = 0
    numberOfReplacedChars = 0
    
    nrOfTopics = 0      
      
    logInsertion: (numberOfCharacters, newTopic) ->
        numberOfChars += numberOfCharacters
        numberOfInsertions++
        if (newTopic)
            nrOfTopics++
    
    logReplacement: (numberOfCharacters) ->
        numberOfReplacedChars += numberOfCharacters
        numberOfReplacements++
    
    getHeader: ->
        return '#Second   \tCharacters\tInserts\tReplacedChars\tReplaces\tTotalChars\tTotalInserts\tTotalTopics\n'
    
    getNextLogString: ->
        numberOfCharsThisSecond = numberOfChars - numberOfCharsAtLastTick
        numberOfInsertionsThisSecond = numberOfInsertions - numberOfInsertionsAtLastTick
        numOfReplacedCharsThisSec = numberOfReplacedChars - numberOfReplacedCharsAtLastTick
        numOfReplacementsThisSec = numberOfReplacements - numberOfReplacementsAtLastTick

        logString =
            util.format('%s \t %s \t %s \t %s \t %s \t %s \t %s \t %s\n'
                       numToStrWithLength((Date.now() % 100000000) / 1000, 10)
                       numToStrWithLength(numberOfCharsThisSecond, 10)
                       numToStrWithLength(numberOfInsertionsThisSecond, 5)
                       numToStrWithLength(numOfReplacedCharsThisSec, 10)
                       numToStrWithLength(numOfReplacementsThisSec, 5)
                       numToStrWithLength(numberOfChars, 10)
                       numToStrWithLength(numberOfInsertions, 10)
                       numToStrWithLength(nrOfTopics, 5)
                       )
        
        numberOfCharsAtLastTick = numberOfChars
        numberOfInsertionsAtLastTick = numberOfInsertions
        numberOfReplacementsAtLastTick = numberOfReplacements
        numberOfReplacedCharsAtLastTick = numberOfReplacedChars
        return logString

    getAverageHeader: ->
        return '# (per sec) Chars\tInserts \tReplacedChars \tReplacements\n'
    
    getAverageString: (testDurationInSec) ->
        averageNumberOfChars = Math.floor(numberOfChars / testDurationInSec)
        averageNumberOfInsertions = Math.floor(numberOfInsertions / testDurationInSec)
        averageNumberOfReplacedChars = Math.floor(numberOfReplacedChars / testDurationInSec)
        averageNumberOfReplaces= Math.floor(numberOfReplacements / testDurationInSec)
        return util.format('     %s    \t%s      \t%s \t%s\n',
                                            numToStrWithLength(averageNumberOfChars, 10)
                                            numToStrWithLength(averageNumberOfInsertions, 5)
                                            numToStrWithLength(averageNumberOfReplacedChars, 10)
                                            numToStrWithLength(averageNumberOfReplaces, 5)
                                            )



exports.InsertionLogger = InsertionLogger