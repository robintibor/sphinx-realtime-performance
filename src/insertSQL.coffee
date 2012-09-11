mysql      = require('mysql')
docId = process.argv[2]
title = process.argv[3]
content = process.argv[4]
gid = process.argv[5]

connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'mastermap',
  port     : 9306
})

connection.connect()

connection.query('INSERT INTO rtwiki VALUES (?, ?, ?, ?)',
 [docId, title, content, gid], (err, rows, fields) ->
  throw err if err
  console.log('rows (insertion result): ', rows)
)
connection.end()
