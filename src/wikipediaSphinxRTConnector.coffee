mysql = require('mysql')
stream = require('stream')

class WikipediaSphinxRTConnector
    mySQLConnection = null
    constructor: ->
        mySQLConnection = mysql.createConnection({
          host     : 'localhost',
          port     : 9306
        })
    
    insertWikiRecord: (newRecord, callback) ->
        mySQLConnection.query(
             #Last Parameter is multi-value-attribute, therefore parentheses needed!
            "INSERT INTO rtwiki(id, topic_id, title, content, user_ids) VALUES(?, ?, ?, ?, (?))"
             [newRecord.id, newRecord.topicId, newRecord.wtitle, newRecord.wtext, newRecord.userIds]
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
            'REPLACE INTO rtwiki(id, topic_id, title, content, user_ids) VALUES(?, ?, ?, ?, (?))'
             [newRecord.id, newRecord.topicId, newRecord.wtitle, newRecord.wtext, newRecord.userIds]
            (err, info) ->
                if (err)
                    console.log('ERROR replacing: ', err)
                    throw err
                callback()
        )
    
    searchForWikiRecord: (searchWord, callback) ->
        mySQLConnection.query(
             #Last Parameter is multi-value-attribute, therefore parantheses needed!
            "SELECT * from rtwiki WHERE MATCH(?)"
             [searchWord]
            (err, info) ->
                if (err)
                    console.log('ERROR searching: ', err)
                    console.log(' word was #{searchWord}')
                    console.log("info", info)
                    throw err
                console.log("results: ", info);
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
exports.WikipediaSphinxRTConnector = WikipediaSphinxRTConnector