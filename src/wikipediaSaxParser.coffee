sax = require('sax')


class WikipediaSaxParser

  fileReadStream = null
  xmlSaxStream = null
  record = {}
  rid = 1

  # to be defined by user of this class, is called when file has been read
  # completely
  endOfFile: () -> 

  onNewRecord: () ->
      

  constructor: (@xmlFilename) ->
    
  pause: ->
      fileReadStream.pause()
  
  resumeParsing: ->
      fileReadStream.resume()
      

  parse: () ->
      setupXmlStream(@onNewRecord)
      setupFileReadStream(@xmlFilename, @endOfFile)     

  setupXmlParser = (callbackForNewRecord) ->
    xmlSaxStream =sax.createStream(false
                                   {
                                    trim: true
                                    normalize: true
                                    lowercase: false
                                   }
                                  )
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
                    callbackForNewRecord(temp)        
                
  setupFileReadStream = (xmlFilename, callbackAtEndOfFile) ->
    fileReadStream = require('fs').createReadStream(
        xmlFilename
        {
        encoding: 'utf8'
        bufferSize: 256 * 1024
        })
    fileReadStrea.pipe(xmlPar
    fileReadStream.on(
        'data'
        (str) ->
            console.log('have read data\n\n\n', str)
            xmlParser.write(str)
            console.log('data written to xml parser\n\n\n', str)
        )
        
        
    fileReadStream.on(
        'end'
        () ->
            callbackAtEndOfFile()
        )

        

exports.WikipediaSaxParser = WikipediaSaxParser