WikipediaSphinxRTConnector = require('./wikipediaSphinxRTConnector').WikipediaSphinxRTConnector
class PerformanceTestSearcher
    # get words
    searchWords = ["and", "or"]
    wikipediaSphinxRTConnector = null

    constructor: ->
        wikipediaSphinxRTConnector = new WikipediaSphinxRTConnector()
    
    makeNextSearchRequest: (callback) ->
        word = "and"
        wikipediaSphinxRTConnector.searchForWikiRecord(word, callback)
        
exports.PerformanceTestSearcher = PerformanceTestSearcher