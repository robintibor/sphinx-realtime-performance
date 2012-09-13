# This script will parse an xml wikimedia dump-file
# and insert the pages as records into a sphinx real time-index
# It uses a queue to synchronize reading/parsing and isnerting to the sphinx
# reading/parsing is faster than inserting, so when more than a certain number of
# inserts have not been completed the parsing is paused until only some
# inserts (numOfInsertsDoneAtOnce, see setupQueue) remain incompleted
readline = require('readline')
queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
PerformanceTestInserter = require('./performanceTestInserter').PerformanceTestInserter

wikiXMLFilename = process.argv[2]
insertQueue = wikipediaSaxParser = performanceTestInserter = null
consoleReader = null
finishedParsing = false

setupPerformanceInserter = ->
    performanceTestInserter = new PerformanceTestInserter()

setupQueue = ->
    insertRecord = (newRecord, callback) ->
        performanceTestInserter.insertRecord(newRecord, callback)
    numOfInsertsDoneAtOnce = 200
    insertQueue = queue(insertRecord, numOfInsertsDoneAtOnce)
    # Shut down program when parsing is finished and all tasks in queue
    # are complete
    insertQueue.drain = () ->
        if (finishedParsing) # parser at e
            performanceTestInserter.close()
    insertQueue.empty = ->
        # Resume parser so that new records will be inserted
        wikipediaSaxParser.resume()

setupParser = ->
    wikipediaSaxParser = new WikipediaSaxParser(wikiXMLFilename)
    wikipediaSaxParser.onNewRecord = (newRecord) -> 
                                        insertQueue.push(newRecord)
                                        if (insertQueue.length() > 100)
                                            # Stop parser to allow inserts into sphinx
                                            # to keep up with parsing speed
                                            wikipediaSaxParser.pause()
    wikipediaSaxParser.endOfFile = () -> 
        finishedParsing = true
        consoleReader.close()

startInserting = ->
    # insertion is done automatically when parser parses new record,
    # see setupParser :)
    wikipediaSaxParser.parse()

listenForUserQuit = ->
    consoleReader = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    })
    consoleReader.question("Press Enter to stop\n", (answer) ->
        wikipediaSaxParser.pause()
        finishedParsing = true
        # prevent queue from resuming parser when empty
        insertQueue.empty = -> 
            console.log("Queue empty, going to quit")
        console.log("Quitting....")
        consoleReader.close()
    )

startInserting = ->
    performanceTestInserter.start()
    wikipediaSaxParser.parse()
    
setupQueue()
setupPerformanceInserter()
setupParser()
startInserting()
listenForUserQuit()
