# Remove all entries of the Realtime-Wiki-Index table..
# Always search for records and delete until there are no more records left
# There will be a TRUNCATE RTINDEX command sphinxQL in the future to do what this script does :)

mysql = require('mysql')

mySQLConnection = mysql.createConnection({
  host     : 'localhost',
  port     : 9306
})

findAndDeleteRecords = () ->
    mySQLConnection.query('SELECT id FROM rtwiki LIMIT 0, 1000',
        (err, info) ->
            if (info.length == 0)
                # Everything deleted, just end connection..
                mySQLConnection.end()
            else
                console.log('deleting', info.length, 'records.')
                deleteRecordWithId(parseInt(record.id)) for record in info
                findAndDeleteRecords()
        )

deleteRecordWithId = (id) ->
    mySQLConnection.query('DELETE FROM rtwiki WHERE id=?'
                          [id]
                (err, info) ->
                    if (err)
                        console.log('ERROR with Id:', id, err)                    
                )

findAndDeleteRecords()