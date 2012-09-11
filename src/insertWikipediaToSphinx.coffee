sax = require('sax')
mysql = require('mysql')
queue = require('async').queue
WikipediaSaxParser = require('./wikipediaSaxParser').WikipediaSaxParser
#
#parser = sax.parser(
#    true
#    {
#        trim: true
#        normalize: true
#        lowercase: false
#    })
#
#client = mysql.createConnection(
#    {
#        host: 'localhost'
#        port: 9306
#    })
#
#insertRecord = (temp, callback) ->
#    client.query(
#        'INSERT INTO rtwiki(id, wid, wtitle, wtext) VALUES(?, ?, ?, ?)'
#        [temp.id, temp.wid, temp.wtitle, temp.wtext]
#        (err, info) ->
#            if (err)
#                console.log('ERROR: ', temp)
#                throw err
#            if temp.id == 1 || temp.id % 1000 == 0
#                console.log('SAVED: ', temp.id, 'TITLE: ', temp.wtitle)
#            callback()
#    )
#insertQueue = queue(insertRecord, 10)
#insertQueue.drain = () ->
#    #console.log("Insert queue length is #{insertQueue.length()}, resuming stream")
#    stream.resume()


wikipediaSaxParser = new WikipediaSaxParser("../wikidata/enwiki.xml.first10906lines")
wikipediaSaxParser.parse((newRecord) -> console.log("new record", newRecord))

