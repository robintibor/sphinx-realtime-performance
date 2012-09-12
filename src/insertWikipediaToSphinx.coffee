queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
WikipediaSphinxRTInserter = require('./wikipediaSphinxRTInserter').WikipediaSphinxRTInserter
InsertionLogger = require('./insertionLogger').InsertionLogger

wikiXMLFilename = process.argv[2]
insertQueue = insertionLogger = wikipediaSphinxRTInserter = wikipediaSaxParser = null
finishedParsing = false

setupQueue = ->
    insertRecord = (newRecord, callback) ->
        # callback to signal 
        wikipediaSphinxRTInserter.insertWikiRecord(newRecord, callback)
        insertionLogger.logInsertion(newRecord.wtext.length)
    numOfTasksDoneAtOnce = 100
    insertQueue = queue(insertRecord, numOfTasksDoneAtOnce)
    insertQueue.drain = () ->
        wikipediaSaxParser.resume()
        if (finishedParsing)
            wikipediaSphinxRTInserter.close()
            insertionLogger.close()

setupParserAndInserter = ->
    wikipediaSphinxRTInserter = new WikipediaSphinxRTInserter()
    insertionLogger = new InsertionLogger('insertionlog.csv')  
    wikipediaSaxParser = new WikipediaSaxParser(wikiXMLFilename)
    wikipediaSaxParser.onNewRecord = (newRecord) -> 
                                        insertQueue.push(newRecord)
                                        if (insertQueue.length > 100)
                                            wikipediaSaxParser.pause()
    wikipediaSaxParser.endOfFile = () -> 
        finishedParsing = true

setupQueue()
setupParserAndInserter()
insertionLogger.start()
wikipediaSaxParser.parse()
