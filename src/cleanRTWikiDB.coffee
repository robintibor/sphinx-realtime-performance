# Remove all entries of the Realtime-Wiki-Index table..
# There will be a TRUNCATE RTINDEX command sphinxQL in the future to do what this script does :)

mysql = require('mysql')

mySQLConnection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'mastermap',
  port     : 9306
})

findAndDeleteRecords = () ->
    mySQLConnection.query('SELECT id FROM rtwiki LIMIT 0, 1000',
        (err, info) ->
            console.log('deleting', info.length, 'records.')
            deleteRecordWithId(parseInt(record.id)) for record in info
            if (info.length == 0)
                setTimeout((() -> mySQLConnection.end()), 1000)
            else
                findAndDeleteRecords()
        )
                

checkIfMoreRecordsExist =  (callback) ->
     mySQLConnection.query('SELECT COUNT(DISTINCT wid) FROM rtwiki'
                            (err, info) ->
                                if (info.length % 100 == 0)
                                    console.log(info.length + " records left.")
                                if (info.length > 0)
                                    callback(true)
                                else
                                    callback(false)
                          )

deleteRecordWithId = (id) ->
    mySQLConnection.query('DELETE FROM rtwiki WHERE id=?'
                          [id]
                (err, info) ->
                    if (err)
                        console.log('ERROR with Id:', id, err)                    
                )

findAndDeleteRecords()