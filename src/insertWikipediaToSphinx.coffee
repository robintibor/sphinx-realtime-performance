sax = require('sax')
mysql = require('mysql')
queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
WikipediaSphinxRTInserter = require('./wikipediaSphinxRTInserter').WikipediaSphinxRTInserter
InsertionLogger = require('./insertionLogger').InsertionLogger


insertRecord = (newRecord, callback) ->
    callback()
    wikipediaSphinxRTInserter.insertWikiRecord(newRecord)
    insertionLogger.logInsertion(newRecord.wtext.length)
    
insertQueue = queue(insertRecord, 10)
insertQueue.drain = () ->
    #console.log("Insert queue length is #{insertQueue.length()}, resuming stream")
    stream.resume()

    

wikipediaSphinxRTInserter = new WikipediaSphinxRTInserter()
insertionLogger = new InsertionLogger('insertionlog.csv')  
wikipediaSaxParser = new WikipediaSaxParser('../wikidata/enwiki.xml')
wikipediaSaxParser.newRecord = (newRecord) -> 
                                    wikipediaSphinxRTInserter.insertWikiRecord(newRecord)
                                    insertionLogger.logInsertion(newRecord.wtext.length)
wikipediaSaxParser.endOfFile = () -> 
    wikipediaSphinxRTInserter.close()
    insertionLogger.close()

insertionLogger.start()
wikipediaSaxParser.parse()
