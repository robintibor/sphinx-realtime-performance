fs = require('fs')
util = require('util')
numToStrWithLength =  require('./utilities').numToStrWithLength
PerformanceLogger = require('./performanceLogger.js').PerformanceLogger

class SearchLogger extends PerformanceLogger
      
    numberOfSearchesAtLastTick = 0
    numberOfSearches = 0
      
    logSearch: () ->
        numberOfSearches++
    
    getHeader: ->
        return '#Second\tSearches\tTotalSearches\n'
    
    getNextLogString: ->
        numberOfSearchesThisSecond = numberOfSearches - numberOfSearchesAtLastTick
        logString =
            util.format('%s \t %s \n'
                       numToStrWithLength((Date.now() % 100000000) / 1000, 10)
                       numToStrWithLength(numberOfSearchesThisSecond, 10)
                       )
        numberOfSearchesAtLastTick = numberOfSearches
        return logString

    getAverageHeader: ->
        return '# Searches per sec\n'
    
    getAverageString: (testDurationInSec) ->
        averageNumberOfSearches = Math.floor(numberOfSearches / testDurationInSec)
        return util.format('     %s\n',
                           numToStrWithLength(averageNumberOfSearches, 10)
                          )

exports.SearchLogger = SearchLogger