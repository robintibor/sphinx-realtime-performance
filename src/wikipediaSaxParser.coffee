sax = require('sax')
class WikipediaSaxParser

  fileReadStream = null
  xmlParser = null
  record = {}
  rid = 1

  constructor: (@xmlFilename) ->
    
  
  pause: ->
      fileReadStream.pause()
  
  resumeParsing: ->
      fileReadStream.resume()
      

  parse: (@callbackForNewRecord) ->
      setupParser()
      fileReadStream = require('fs').createReadStream(
        @xmlFilename
        {
        encoding: 'utf8'
        bufferSize: 256 * 1024
        })

      fileReadStream.on(
        'data'
        (str) ->
            xmlParser.write(str)
        )

  setupParser = ->
    xmlParser = sax.parser(
        true
        {
            trim: true
            normalize: true
            lowercase: false
        })
    
    xmlParser.onerror = (e) ->
        console.log('ERROR: ', e)
        process.exit(-1)
        
    xmlParser.ontext = (t) ->
        if xmlParser.tag == null then return
        switch xmlParser.tag.name
            when 'id'
                record.wid ?= t
            when 'title'
                record.wtitle = t
            when 'text'
                record.wtext = t
        		 
        xmlParser.onopentag = (tag) ->
            if (tag.name == 'page')
                record = {}
        
        xmlParser.onclosetag = (tag) ->
            if(tag == 'page')
                # saving record
                temp = record
                temp.id = rid
                rid += 1
                if (temp.wid? && temp.wtitle? && temp.wtext?)
                    if (temp.id <= 12337000)
                        if (temp.id == 1 || temp.id % 1000 == 0)
                            console.log('SKIPPED: ', temp.id, 'TITLE: ', temp.wtitle)
                        return
                    @callbackForNewRecord(temp)
        
        xmlParser.end = () ->
            console.log('DONE.')
            client.query(
                'FLUSH RTINDEX rtwiki'
                (err, info)->
                    if (err) then throw err
                    console.log('FLUSHED.')
                    client.end()
                )


exports.WikipediaSaxParser = WikipediaSaxParser