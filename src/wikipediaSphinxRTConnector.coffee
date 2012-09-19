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
        sphinxQLString = 'SELECT * FROM rtwiki WHERE user_ids =  ? AND MATCH(?) '
        if (groupByTopic)
            sphinxQLString += 'GROUP BY topic_id '
        sphinxQLString +=  'LIMIT 300'
        mySQLConnection.query(
             sphinxQLString
             [userId, searchString]
            (err, result) ->
                if (err)
                    console.log('ERROR searching: ', err)
                    console.log("info", result)
                    throw err
                callback()
        )
    
    # This will try to find the highest user id in the following way:
    # Search for blips with user ids higher than the given user id
    # Group them by topic to get more results for one query
    # and then go through result user ids to find biggest one..
    getHighestUserId: (oldHighestUserId, callback) ->
        mySQLConnection.query(
             #Last Parameter is multi-value-attribute, therefore parentheses needed!
            'SELECT user_ids FROM rtwiki WHERE user_ids > ? GROUP BY topic_id'
             [oldHighestUserId]
            (err, result) ->
                if (err)
                    console.log('Could not search for highest user:', err)
                    throw err
                if (result.length == 0)
                    callback(oldHighestUserId)
                else
                    maxUserId = getHighestUserIdOfResultSet(result)
                    callback(maxUserId)
        )
    
    getHighestUserIdOfResultSet = (queryResult) ->
        # first line: parse result user ids strings to int user ids...
        # second and third line: http://coffeescriptcookbook.com/chapters/arrays/max-array-value :)
        allUserIds = (JSON.parse("[" + record.user_ids + "]") for record in queryResult)
        highestUserIds = (Math.max userIds... for userIds in allUserIds)
        return Math.max highestUserIds...
    
    close: () ->
            mySQLConnection.query(
                'FLUSH RTINDEX rtwiki'
                (err, info)->
                    if (err) then throw err
                    console.log('Done, closing Sphinx Connection.')
                    mySQLConnection.end()
                )
exports.WikipediaSphinxRTConnector = WikipediaSphinxRTConnector