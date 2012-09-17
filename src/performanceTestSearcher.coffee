WikipediaSphinxRTConnector = require('./wikipediaSphinxRTConnector').WikipediaSphinxRTConnector
class PerformanceTestSearcher
    
    chanceOfGrouping = 2/3
    chanceOfTwoWordSearch = 0.1
    chanceOfOneWordSearch = 0.2
    # get words
    allSearchWords = ["and", "or"]
    wikipediaSphinxRTConnector = null
    userId = 0

    constructor: ->
        wikipediaSphinxRTConnector = new WikipediaSphinxRTConnector()
    
    makeNextSearchRequest: (callback) ->
        word = "and"
        numberOfWordsForSearch = decideNumberOfWords()
        userId = getRandomUserId()
        makeSearchRequest(userId, numberOfWordsForSearch, callback)
    
    decideNumberOfWords = ->
        randomNumber = Math.random()
        if (randomNumber < chanceOfTwoWordSearch)
            return 2
        else if (randomNumber < chanceOfTwoWordSearch + chanceOfOneWordSearch)
            return 1
        else
            return 0        
    
    getRandomUserId = () ->
        return 1;
    
    makeSearchRequest = (userId, numberOfWords, callback) ->
        searchShouldBeGrouped = decideIfSearchShouldBeGrouped(numberOfWords)
        searchWords = getWords(numberOfWords)
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
        wikipediaSphinxRTConnector.close()
exports.PerformanceTestSearcher = PerformanceTestSearcher