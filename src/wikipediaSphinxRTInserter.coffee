mysql = require('mysql')
stream = require('stream')

class WikipediaSphinxRTInserter extends stream.Stream
    mySQLConnection = null
    constructor: ->
        @writable = true
        mySQLConnection = mysql.createConnection({
          host     : 'localhost',
          user     : 'root',
          password : 'mastermap',
          port     : 9306
        })
    
    write: (newRecord) ->
        insertWikiRecord(newRecord)
    
    end: ->
        close()
    
    insertWikiRecord: (newRecord) =>
        console.log('inserting wiki record' , newRecord.id)
        mySQLConnection.query(
            'INSERT INTO rtwiki(id, wid, wtitle, wtext) VALUES(?, ?, ?, ?)'
             [newRecord.id, newRecord.wid, newRecord.wtitle, newRecord.wtext]
            (err, info) ->
                console.log('inserted wiki record' , newRecord.id)
                if (err)
                    console.log('ERROR: ', newRecord)
                    throw err
                if newRecord.id == 1 || newRecord.id % 1000 == 0
                    console.log('SAVED: ', newRecord.id, 'TITLE: ', newRecord.wtitle)
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