queue = require('async').queue
readline = require('readline')
PerformanceTestSearcher = require('./performanceTestSearcher.js').PerformanceTestSearcher

numOfTasksDoneAtOnce = 130
numOfMaximumQueuedTasks = 50
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

# ask for word

# maybe ask for specific user?

# log search times