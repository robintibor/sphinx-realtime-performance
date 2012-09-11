queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
WikipediaSphinxRTInserter = require('./wikipediaSphinxRTInserter').WikipediaSphinxRTInserter
InsertionLogger = require('./insertionLogger').InsertionLogger


insertRecord = (newRecord, callback) ->
    wikipediaSphinxRTInserter.insertWikiRecord(newRecord)
    insertionLogger.logInsertion(newRecord.wtext.length)
    callback()
    
insertQueue = queue(insertRecord, 1)
insertQueue.drain = () ->
    console.log("Insert queue length is #{insertQueue.length()}, resuming stream")
    wikipediaSaxParser.resumeParsing()

    

wikipediaSphinxRTInserter = new WikipediaSphinxRTInserter()
insertionLogger = new InsertionLogger('insertionlog.csv')  
wikipediaSaxParser = new WikipediaSaxParser('../wikidata/enwiki.xml.first1000000')
wikipediaSaxParser.onNewRecord = (newRecord) -> 
                                    insertQueue.push(newRecord)
                                    if (insertQueue.length > 100)
                                        wikipediaSaxParser.pause()
wikipediaSaxParser.endOfFile = () -> 
    wikipediaSphinxRTInserter.close()
    insertionLogger.close()

insertionLogger.start()
wikipediaSaxParser.parse()
