queue = require('async').queue
PerformanceTestSearcher = require('./performanceTestSearcher.js').PerformanceTestSearcher

numOfTasksDoneAtOnce = 300
numOfMaximumQueuedTasks = 200

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
        console.log("queue empty")
        # Resume searching for next records
        continouslyMakeSearches()
    insertQueue.drain = ->
        console.log('insert queue drained, no tasks are done at the moment, should not happen')

continouslyMakeSearches = ->
    while (insertQueue.length() < numOfMaximumQueuedTasks)
        insertQueue.push({})

setupQueue()
continouslyMakeSearches()
# ask for word

# maybe ask for specific user?

# log search times