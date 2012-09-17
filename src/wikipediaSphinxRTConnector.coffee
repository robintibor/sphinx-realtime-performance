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
    
    searchForUserBlips: (userId, searchWords, groupByTopic, callback) ->
        searchString = searchWords.join(' ')
        # ? will be replaced by searchString
        sphinxQLString = 'SELECT * FROM rtwiki WHERE MATCH(?) '
        if (groupByTopic)
            sphinxQLString += 'GROUP BY topic_id '
        sphinxQLString +=  'LIMIT 300'
        mySQLConnection.query(
             #Last Parameter is multi-value-attribute, therefore parantheses needed!
             sphinxQLString
             [searchString]
            (err, info) ->
                if (err)
                    console.log('ERROR searching: ', err)
                    console.log(' word was #{searchWords}')
                    console.log("info", info)
                    throw err
                callback()
        )

    close: () ->
            mySQLConnection.query(
                'FLUSH RTINDEX rtwiki'
                (err, info)->
                    if (err) then throw err
                    console.log('Done, closing Sphinx Connection.')
                    mySQLConnection.end()
                )
exports.WikipediaSphinxRTConnector = WikipediaSphinxRTConnector