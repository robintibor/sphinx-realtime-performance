InsertionLogger = require('../lib/insertionLogger').InsertionLogger


exports.testLogging = (test) -> 
    test.expect(1)
    # Create Insertion Logger, make one insertion and check that logfile exists
    testFileName = 'temp/testLogFileName'
    insertionLogger = new InsertionLogger(testFileName)
    insertionLogger.start()
    insertionLogger.logInsertion(3000)
    setTimeout(( -> 
        insertionLogger.close()
        stats = require('fs').lstatSync(testFileName)              
        test.ok(stats.isFile())
        test.done()
        ), 1000)
    