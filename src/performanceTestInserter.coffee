WikipediaSphinxRTInserter = require('./wikipediaSphinxRTInserter').WikipediaSphinxRTInserter
InsertionLogger = require('./insertionLogger').InsertionLogger
# TODO: output total number of topics as well and output average statistics
# and do soemthing about user ids!
class PerformanceTestInserter
    numberOfReplacementsPerInsert = 20
    numberOfBlipsPerTopic = 30
    wikipediaSphinxRTInserter = insertionLogger = null
    blipId = 0  # is used assphinx doc id in theses tests!
    topicId = 0

    constructor: ->
        wikipediaSphinxRTInserter = new WikipediaSphinxRTInserter()
        timeStamp = JSON.stringify(new Date()).replace(/"/g, '')
        insertionLogger = new InsertionLogger('perfdata/insertionlog' +
            timeStamp + '.csv')
    
    start: ->
        insertionLogger.start()
    
    insertRecord: (newRecord, callback) ->
        processRecord = decideWhatToDoWithTheRecord()
        processRecord(newRecord, callback)

    decideWhatToDoWithTheRecord = ->
        firstBlipWasInserted = blipId > 0
        chanceOfReplacement = Math.random()
        if (chanceOfReplacement > (1 / numberOfReplacementsPerInsert) && firstBlipWasInserted)
            return updateBlip
        else 
            return insertNewBlip
    
    updateBlip = (newRecord, callback) ->
        replaceBlipId = getRandomNumberCloseTo(blipId)
        newRecord.id = replaceBlipId
        wikipediaSphinxRTInserter.updateWikiRecord(newRecord, callback)
        insertionLogger.logReplacement(newRecord.wtext.length)
        
    insertNewBlip = (newRecord, callback) ->
        blipId++
        newRecord.id = blipId
        processBlip = decideWhatToDoWithNewBlip()
        processBlip(newRecord, callback)

    decideWhatToDoWithNewBlip = ->
        chanceOfOldTopic = Math.random()
        if (chanceOfOldTopic > (1 / numberOfBlipsPerTopic))
            return insertBlipToExistingTopic
        else
            return insertBlipToNewTopic

    insertBlipToExistingTopic = (newRecord, callback) ->
        newRecord.topicId = getRandomNumberCloseTo(topicId)
        wikipediaSphinxRTInserter.insertWikiRecord(newRecord, callback)
        insertionLogger.logInsertion(newRecord.wtext.length)
        
    insertBlipToNewTopic = (newRecord, callback) ->
        topicId++
        newRecord.topicId = topicId 
        wikipediaSphinxRTInserter.insertWikiRecord(newRecord, callback)
        insertionLogger.logInsertion(newRecord.wtext.length)
    
    # this will return the given number with a chance of 1/2
    # return the given number -1 with chance 1/4
    # return the given number -2 with chance 1/8
    # ...
    # (but always returns a non-negative number,
    # for negative numbers it will return 0)
    getRandomNumberCloseTo = (num) ->
        biggestNum = num
        randomNumber = Math.random()
        if (randomNumber == 0.0) 
            return 0 # for safety reasons :)
        else
            offset = Math.floor(Math.log((1 / randomNumber)) / Math.LN2)
            return Math.max(0, biggestNum - offset)
        
    close: ->
        insertionLogger.writeAverageStatistics()
        wikipediaSphinxRTInserter.close()
        insertionLogger.close()

exports.PerformanceTestInserter = PerformanceTestInserter