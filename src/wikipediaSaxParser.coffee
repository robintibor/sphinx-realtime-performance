sax = require('sax')


class WikipediaSaxParser

  fileReadStream = null
  xmlSaxStream = null
  record = {}

  # to be defined by user of this class, is called when file has been read
  # completely
  endOfFile: () -> 

  # to be defined by user of this class, is called when new record 
  # has been parsed
  onNewRecord: () ->
      

  constructor: (@xmlFilename) ->
    
  pause: ->
      fileReadStream.pause()
  
  resume: ->
      fileReadStream.resume()
      

  parse: () ->
      setupXmlStream(@onNewRecord)
      setupFileReadStream(@xmlFilename, @endOfFile)     

  setupXmlStream = (callbackForNewRecord) ->
    xmlSaxStream = sax.createStream(false
                                    {
                                        trim: true
                                        normalize: true
                                        lowercase: false
                                    })
                              
    xmlSaxStream.on('error', (e) ->
        console.log('ERROR: ', e)
        process.exit(-1)
    )
    
    xmlSaxStream.on('text', (text) ->
        if xmlSaxStream._parser.tag == null then return
        # TODO(robintibor@gmail.com): ignore tag entirely if
        # currently not inside a page node
        switch xmlSaxStream._parser.tag.name
            when 'TITLE'
                record.wtitle = text
            when 'TEXT'
                record.wtext = text
        )
                 
    xmlSaxStream.on('opentag', (tag) ->
            if (tag.name == 'PAGE')
                record = {}
            )
    
    xmlSaxStream.on('closetag', (tag) ->
            if(tag == 'PAGE')
                # saving record
                temp = record
                if (temp.wtitle? && temp.wtext?)
                    callbackForNewRecord(temp)  
            )
                
  setupFileReadStream = (xmlFilename, callbackAtEndOfFile) ->
    fileReadStream = require('fs').createReadStream(
        xmlFilename
        {
        encoding: 'utf8'
        bufferSize: 256 * 1024
        })
        
    fileReadStream.pipe(xmlSaxStream)
        
    fileReadStream.on(
        'end'
        () ->
            callbackAtEndOfFile()
        )

        

exports.WikipediaSaxParser = WikipediaSaxParser