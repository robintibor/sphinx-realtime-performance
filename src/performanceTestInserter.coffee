WikipediaSphinxRTInserter = require('./wikipediaSphinxRTInserter').WikipediaSphinxRTInserter
InsertionLogger = require('./insertionLogger').InsertionLogger

class PerformanceTestInserter
    wikipediaSphinxRTInserter = insertionLogger = null
    constructor: ->
        wikipediaSphinxRTInserter = new WikipediaSphinxRTInserter()
        insertionLogger = new InsertionLogger('perfdata/insertionlog' +
            JSON.stringify(new Date()) + '.csv')
    
    start: ->
        insertionLogger.start()
    
    insertRecord: (newRecord, callback) ->
        # callback to signal 
        wikipediaSphinxRTInserter.insertWikiRecord(newRecord, callback)
        insertionLogger.logInsertion(newRecord.wtext.length)
    
    close: ->
        insertionLogger.writeAverageStatistics()
        wikipediaSphinxRTInserter.close()
        insertionLogger.close()

exports.PerformanceTestInserter = PerformanceTestInserter