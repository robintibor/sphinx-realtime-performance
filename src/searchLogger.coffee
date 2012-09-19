fs = require('fs')
util = require('util')
numToStrWithLength =  require('./utilities').numToStrWithLength
PerformanceLogger = require('./performanceLogger.js').PerformanceLogger

class SearchLogger extends PerformanceLogger
      
    numberOfSearches = 0
    numberOfGroupedSearches = 0
    numberOfUnGroupedSearches = 0
    numberOfOneWordSearches = 0
    numberOfTwoWordSearches = 0
    numberOfGroupedSearchesAtLastTick = 0
    numberOfUnGroupedSearchesAtLastTick = 0
    numberOfOneWordSearchesAtLastTick = 0
    numberOfTwoWordSearchesAtLastTick = 0
    totalSearchesAtLastTick = 0

    logSearch: (numberOfWords, groupedSearch) ->
        if (numberOfWords == 0)
            if (groupedSearch)
                logGroupedSearch()
            else
                logUnGroupedSearch()
        else if (numberOfWords == 1)
            logOneWordSearch()
        else if (numberOfWords == 2)
            logTwoWordSearch()
    
    logGroupedSearch = ->
        numberOfGroupedSearches++
        
    logUnGroupedSearch = ->
        numberOfUnGroupedSearches++
        
    logOneWordSearch = ->
        numberOfOneWordSearches++
    
    logTwoWordSearch = ->
        numberOfTwoWordSearches++
    
    getHeader: ->
        return '#Second\tGrouped\tUngrouped\tOneWord\tTwoWord\Searches\tTotalSearches\n'
    
    getNextLogString: ->
        numGroupedSearchesThisSec= numberOfGroupedSearches - numberOfGroupedSearchesAtLastTick
        numUnGroupedSearchesThisSec= numberOfUnGroupedSearches - numberOfUnGroupedSearchesAtLastTick
        numOneWordSearchesThisSec= numberOfOneWordSearches - numberOfOneWordSearchesAtLastTick
        numTwoWordSearchesThisSec= numberOfTwoWordSearches - numberOfTwoWordSearchesAtLastTick
        totalSearches = numberOfGroupedSearches + numberOfUnGroupedSearches +
            numberOfOneWordSearches + numberOfTwoWordSearches
        totalSearchesThisSec = totalSearches - totalSearchesAtLastTick
        
        logString =
            util.format('%s \t %s \t %s \t %s \t %s \t %s \t %s \n'
                       numToStrWithLength((Date.now() % 100000000) / 1000, 10)
                       numToStrWithLength(numGroupedSearchesThisSec, 10)
                       numToStrWithLength(numUnGroupedSearchesThisSec, 10)
                       numToStrWithLength(numOneWordSearchesThisSec, 10)
                       numToStrWithLength(numTwoWordSearchesThisSec, 10)
                       numToStrWithLength(totalSearchesThisSec, 10)
                       numToStrWithLength(totalSearches, 10)
                       )
        
        numberOfGroupedSearchesAtLastTick= numberOfGroupedSearches
        numberOfUnGroupedSearchesAtLastTick= numberOfUnGroupedSearches
        numberOfOneWordSearchesAtLastTick= numberOfOneWordSearches
        numberOfTwoWordSearchesAtLastTick= numberOfTwoWordSearches
        totalSearchesAtLastTick = totalSearches
        return logString

    getAverageHeader: ->
        return '# (/sec) Grouped\tUngrouped\tOneWord\t        TwoWord \t    TotalSearches\n'
    
    getAverageString: (testDurationInSec) ->
        totalSearches = numberOfGroupedSearches + numberOfUnGroupedSearches +
            numberOfOneWordSearches + numberOfTwoWordSearches
        averageNumberOfGroupedSearches = Math.floor(numberOfGroupedSearches / testDurationInSec)
        averageNumberOfUnGroupedSearches = Math.floor(numberOfUnGroupedSearches / testDurationInSec)
        averageNumberOfOneWordSearches = Math.floor(numberOfOneWordSearches / testDurationInSec)
        averageNumberOfTwoWordSearches = Math.floor(numberOfTwoWordSearches / testDurationInSec)
        averageNumberOfSearches = Math.floor(totalSearches / testDurationInSec)
        return util.format('     %s\t%s\t%s\t%s\t%s\n',
                           numToStrWithLength(averageNumberOfGroupedSearches, 12)
                           numToStrWithLength(averageNumberOfUnGroupedSearches, 9)
                           numToStrWithLength(averageNumberOfOneWordSearches, 9)
                           numToStrWithLength(averageNumberOfTwoWordSearches, 9)
                           numToStrWithLength(averageNumberOfSearches, 9)
                          )

exports.SearchLogger = SearchLogger