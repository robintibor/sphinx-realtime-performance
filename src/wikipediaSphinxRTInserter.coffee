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
            'INSERT INTO rtwiki(id, topic_id, title, content, user_ids) VALUES(?, ?, ?, ?, (1,2,3))'
             [newRecord.id, newRecord.topicId, newRecord.wtitle, newRecord.wtext]
            (err, info) ->
                if (err)
                    console.log('ERROR inserting: ', err)
                    console.log("Id was #{newRecord.id}")
                    console.log("info", info)
                    throw err
                callback()
        )
        
    updateWikiRecord: (newRecord, callback) ->
        mySQLConnection.query(
            'REPLACE INTO rtwiki(id, title, content, user_ids) VALUES(?, ?, ?, (1,2,3))'
             [newRecord.id, newRecord.wtitle, newRecord.wtext]
            (err, info) ->
                if (err)
                    console.log('ERROR replacing: ', err)
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