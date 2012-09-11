InsertionLogger = require('../insertionLogger').InsertionLogger

exports.testLogging = (test) -> 
    test.expect(1)
    # Create Insertion Logger, make one insertion and check that logfile exists
    insertionLogger = new InsertionLogger('testLogFileName')
    insertionLogger.start()
    insertionLogger.logInsertion(3000)
    setTimeout(( ->
        insertionLogger.close()
        stats = require('fs').lstatSync('testLogFileName')              
        test.ok(stats.isFile())
        console.log('ok')
        test.done()
        ), 1000)