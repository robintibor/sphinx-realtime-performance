#This script will perform searches on the sphinx database continously...
# Every second it will also make one request to update the highest user id...

queue = require('async').queue
readline = require('readline')
WikipediaSphinxRTConnector = require('./wikipediaSphinxRTConnector').WikipediaSphinxRTConnector
SearchLogger = require('./searchLogger').SearchLogger

numOfTasksDoneAtOnce = 130
numOfMaximumQueuedTasks = 50
chanceOfGrouping = 2/3
chanceOfTwoWordSearch = 0.1
chanceOfOneWordSearch = 0.2

class PerformanceTestSearcher
    
    # get words
    allSearchWords = ['the', 'be', 'to', 'of', 'and', 'a', 'in', 'that', 'have', 'I', 'it', 'for', 'not', 'on', 'with', 'he', 'as', 'you', 'do', 'at', 'this', 'but', 'his', 'by', 'from', 'they', 'we', 'say', 'her', 'she', 'or', 'an', 'will', 'my', 'one', 'all', 'would', 'there', 'their', 'what', 'so', 'up', 'out', 'if', 'about', 'who', 'get', 'which', 'go', 'me', 'when', 'make', 'can', 'like', 'time', 'no', 'just', 'him', 'know', 'take', 'people', 'into', 'year', 'your', 'good', 'some', 'could', 'them', 'see', 'other', 'than', 'then', 'now', 'look', 'only', 'come', 'its', 'over', 'think', 'also', 'back', 'after', 'use', 'two', 'how', 'our', 'work', 'first', 'well', 'way', 'even', 'new', 'want', 'because', 'any', 'these', 'give', 'day', 'most', 'us']
    wikipediaSphinxRTConnector = searchLogger = null
    updateUserInterval = null
    maxUserId = 1

    constructor: ->
        wikipediaSphinxRTConnector = new WikipediaSphinxRTConnector()
        timeStamp = JSON.stringify(new Date()).replace(/"/g, '')
        searchLogger = new SearchLogger('perfdata/searchlog' +
            timeStamp + '.csv')
    
    start: ->
        searchLogger.start()
        continuouslyUpdateUserId()
    
    continuouslyUpdateUserId = ->
        updateUserInterval = setInterval(updateMaxUserId, 1000)
    
    updateMaxUserId = ->
        wikipediaSphinxRTConnector.getHighestUserId(maxUserId, (newMaxUserId) ->
            maxUserId = newMaxUserId)
            
    
    makeNextSearchRequest: (callback) ->
        numberOfWordsForRequest= chooseNumberOfWords()
        userId = getRandomUserId()
        makeSearchRequest(userId, numberOfWordsForRequest, callback)
    
    chooseNumberOfWords = ->
        randomNumber = Math.random()
        if (randomNumber < chanceOfTwoWordSearch)
            return 2
        else if (randomNumber < chanceOfTwoWordSearch + chanceOfOneWordSearch)
            return 1
        else
            return 0        
    
    getRandomUserId = () ->
        return Math.floor(Math.random() * maxUserId)
    
    makeSearchRequest = (userId, numberOfWords, callback) ->
        searchShouldBeGrouped = decideIfSearchShouldBeGrouped(numberOfWords)
        searchWords = getWords(numberOfWords)
        searchLogger.logSearch()
        wikipediaSphinxRTConnector.searchForUserBlips(userId, searchWords, searchShouldBeGrouped, callback)
    
    decideIfSearchShouldBeGrouped = (numberOfWords) ->
        if numberOfWords == 0
            return Math.random() < chanceOfGrouping
        else
            return false
    
    
    getWords = (numberOfWords) ->
        if (numberOfWords == 0) 
            return []
        else
            words = (getRandomSearchWord() for i in [1..numberOfWords])
            return words
        
    getRandomSearchWord = ->
        return allSearchWords[Math.floor(Math.random() * allSearchWords.length)]
    
    close: ->
        clearInterval(updateUserInterval)
        searchLogger.writeAverageStatistics()
        searchLogger.close()
        wikipediaSphinxRTConnector.close()

exports.PerformanceTestSearcher = PerformanceTestSearcher

searchingFinished = false;
# just always search for the same word, search for and or something...

insertQueue = performanceTestSearcher = null
performanceTestSearcher = new PerformanceTestSearcher()

setupQueue = ->
    makeSearchRequest = (emptyObject, callback) ->
        performanceTestSearcher.makeNextSearchRequest(callback)
    insertQueue = queue(makeSearchRequest, numOfTasksDoneAtOnce)
    # Shut down program when parsing is finished and all tasks in queue
    # are complete
    insertQueue.empty = ->
        # Resume making searches
        continouslyMakeSearches()
    insertQueue.drain = ->
        if (searchingFinished)
            performanceTestSearcher.close()
        else
            console.log('insert queue drained, no tasks are done at the moment, should only happen at the end')
            
startLogging = ->
    performanceTestSearcher.start()

continouslyMakeSearches = ->
    while (insertQueue.length() < numOfMaximumQueuedTasks && ! searchingFinished)
        insertQueue.push({})

listenForUserQuit = ->
    consoleReader = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    })
    consoleReader.question("Press Enter to stop\n", (answer) ->
        searchingFinished = true
        # prevent queue from resuming searches when empty
        insertQueue.empty = -> 
            console.log("Queue empty, #{insertQueue.concurrency} tasks remaining...")
        console.log("Quitting, waiting for #{insertQueue.concurrency + insertQueue.length()} tasks.")
        consoleReader.close()
    )

setupQueue()
startLogging()
continouslyMakeSearches()
listenForUserQuit()
