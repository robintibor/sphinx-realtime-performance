WikipediaSphinxRTConnector = require('./wikipediaSphinxRTConnector').WikipediaSphinxRTConnector
InsertionLogger = require('./insertionLogger').InsertionLogger
PerformanceLogger = require('./performanceLogger.js').PerformanceLogger

class PerformanceTestInserter
    numberOfReplacementsPerInsert = 20
    numberOfBlipsPerTopic = 30
    wikipediaSphinxRTConnector = insertionLogger = null
    blipId = 0  # is used as sphinx doc id in theses tests!
    topicId = 1
    userId = 5
    currentTopic = null

    constructor: ->
        wikipediaSphinxRTConnector = new WikipediaSphinxRTConnector()
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
        replaceBlipId = getRandomBlipIdOfCurrentTopic
        newRecord.id = replaceBlipId
        setRecordInfo(newRecord, replaceBlipId)
        wikipediaSphinxRTConnector.updateWikiRecord(newRecord, callback)
        insertionLogger.logReplacement(newRecord.wtext.length)
    
    getRandomBlipIdOfCurrentTopic = () ->
        startBlipIdOfCurrentTopic = blipId - currentTopic.numberOfInsertedBlips + 1
        return Math.floor(Math.random() * currentTopic.numberOfInsertedBlips + startBlipIdOfCurrentTopic)

    insertNewBlip = (newRecord, callback) ->
        if (currentTopicHasAllBlipsInserted())
            createNextTopic()
        insertBlipToCurrentTopic(newRecord, callback)

    currentTopicHasAllBlipsInserted = ->
        return currentTopic == null || 
            currentTopic.numberOfInsertedBlips == currentTopic.numberOfBlips

    createNextTopic = ->
        topicId++
        userId++
        userIds = createUserIdsForTopic()
        numberOfBlips = getNumberOfBlipsForTopic()
        currentTopic = {
            'userIds' : userIds,
            'numberOfBlips': numberOfBlips,
            'numberOfInsertedBlips': 0
        }
        return currentTopic
            
    getNumberOfBlipsForTopic = ->
        return Math.floor(Math.random() * 95 + 5) # between 5 and 100
    
    createUserIdsForTopic = ->
        numUsers = getNumberOfUsersForTopic()
        userIds = getUserIdsForTopic(numUsers)
        return userIds
    
    getNumberOfUsersForTopic = ->
        # TODO(robintibor@gmail.com): make so that it is not distributed equally
        # but more topics with 5-20 users than with 20-100
        # and more from 20-100 than from 100-200 etc.
        maxUsersForTopic = Math.min(userId / 4, 200)
        # we want a minimal amount of users, 5 
        # This will yield  between 5 and 200 or 5 and number of users
        # atelast after there are 20 users, before i t might be less
        return Math.floor((Math.random() * (maxUsersForTopic - 5)) + 5)
    
    getUserIdsForTopic = (numUsers) ->
        userIdSet = {}
        maxUserId = userId
        # always push last user in
        userIdSet[maxUserId] = true
        # randomly push user ids in set..
        usersAdded = 1
        while (usersAdded != numUsers)
            nextUserId = Math.round(Math.random() * maxUserId)
            if (userIdSet[nextUserId] != true)
                userIdSet[nextUserId] = true
                usersAdded++
        # unpack set
        userIds = (parseInt(userIdString) for userIdString in Object.keys(userIdSet))
        return userIds
    
    insertBlipToCurrentTopic = (newRecord, callback) ->
        blipId++
        setRecordInfo(newRecord, blipId)
        wikipediaSphinxRTConnector.insertWikiRecord(newRecord, callback)
        isNewTopic = currentTopic.numberOfInsertedBlips == 0
        insertionLogger.logInsertion(newRecord.wtext.length, isNewTopic)
        currentTopic.numberOfInsertedBlips++
    
    setRecordInfo = (newRecord, id) ->
        newRecord.id = blipId
        newRecord.topicId = topicId
        newRecord.userIds = currentTopic.userIds 
    
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
        insertionLogger.close()
        wikipediaSphinxRTConnector.close()

exports.PerformanceTestInserter = PerformanceTestInserter