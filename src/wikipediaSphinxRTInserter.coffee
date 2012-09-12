mysql = require('mysql')
stream = require('stream')

class WikipediaSphinxRTInserter
    mySQLConnection = null
    constructor: ->
        mySQLConnection = mysql.createConnection({
          host     : 'localhost',
          user     : 'root',
          password : 'mastermap',
          port     : 9306
        })
    
    insertWikiRecord: (newRecord, callback) ->
        mySQLConnection.query(
            'INSERT INTO rtwiki(id, wid, wtitle, wtext) VALUES(?, ?, ?, ?)'
             [newRecord.id, newRecord.wid, newRecord.wtitle, newRecord.wtext]
            (err, info) ->
                if (err)
                    console.log('ERROR inserting: ', err)
                    throw err
                callback()
        )

    close: () ->
            mySQLConnection.query(
                'FLUSH RTINDEX rtwiki'
                (err, info)->
                    if (err) then throw err
                    console.log('Done inserting, flushed To Index.')
                    mySQLConnection.end()
                )
exports.WikipediaSphinxRTInserter = WikipediaSphinxRTInserter