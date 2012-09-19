readline = require('readline')
queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
PerformanceTestInserter = require('../lib/performanceTestInserter.js').PerformanceTestInserter

numOfTasksDoneAtOnce = 200
numOfMaximumQueuedTasks = 100

## Main function
wikiXMLFilename = process.argv[2]
insertQueue = wikipediaSaxParser = performanceTestInserter = null
consoleReader = null
finishedParsing = false

setupPerformanceInserter = ->
    performanceTestInserter = new PerformanceTestInserter()

setupQueue = ->
    insertRecord = (newRecord, callback) ->
        performanceTestInserter.insertRecord(newRecord, callback)
    insertQueue = queue(insertRecord, numOfTasksDoneAtOnce)
    # Shut down program when parsing is finished and all tasks in queue
    # are complete
    insertQueue.drain = () ->
        if (finishedParsing)
            performanceTestInserter.close()
    insertQueue.empty = ->
        # Resume parser so that new records will be inserted
        wikipediaSaxParser.resume()

setupParser = ->
    wikipediaSaxParser = new WikipediaSaxParser(wikiXMLFilename)
    wikipediaSaxParser.onNewRecord = (newRecord) -> 
                                        insertQueue.push(newRecord)
                                        if (insertQueue.length() > numOfMaximumQueuedTasks)
                                            # Stop parser to allow inserts into sphinx
                                            # to keep up with parsing speed
                                            wikipediaSaxParser.pause()
    wikipediaSaxParser.endOfFile = () -> 
        finishedParsing = true
        consoleReader.close()

startInserting = ->
    performanceTestInserter.start()
    # insertion is done automatically when parser parses new record,
    # see setupParser :)
    wikipediaSaxParser.parse()

listenForUserQuit = ->
    consoleReader = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    })
    consoleReader.question("Press Enter to stop\n", (answer) ->
        # prevent queue from resuming parser when empty
        insertQueue.empty = -> 
            console.log("Queue empty, #{insertQueue.concurrency} tasks remaining...")
        finishedParsing = true
        wikipediaSaxParser.pause()
        console.log("Quitting, waiting for #{insertQueue.concurrency + insertQueue.length()} tasks.")
        consoleReader.close()
    )

    
setupQueue()
setupPerformanceInserter()
setupParser()
startInserting()
listenForUserQuit()
