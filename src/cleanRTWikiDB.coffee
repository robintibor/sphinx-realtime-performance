# Remove all entries of the table..

mysql = require('mysql')

mySQLConnection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'mastermap',
  port     : 9306
})

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
                        console.log('ERROR with Id: ', id)
                    checkIfMoreRecordsExist(
                        (moreRecords) -> 
                            if (moreRecords)
                                if id % 100 == 0
                                    console.log("deleted id " + id)
                                deleteRecordWithId (id + 1)
                            else
                                mySQLConnection.end()
                    )
                )

deleteRecordWithId(0)