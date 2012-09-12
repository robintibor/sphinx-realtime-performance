fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'
exec = require('child_process').exec


build = (callback) ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

runJitter = (argumentsForJitter) ->
    jitter = spawn 'jitter', argumentsForJitter
    jitter.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    jitter.stdout.on 'data', (data) ->
      print data.toString()

task 'build', 'Build lib/ from src/', ->
  build()

task 'setup-auto-compiling-and-testing', 'compile src and test on changes, run test on changes', ->
    jitter = spawn 'jitter', ['src', 'lib', 'test']
    jitter.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    jitter.stdout.on 'data', (data) ->
      print data.toString()

task 'auto-compile', 'compiles src and test on changes wihtout running tests', ->
    runJitter(['src', 'lib'])
    runJitter(['test', 'test'])

option '', '--inputfile [Filename]', 'Filename tof wikipedia xml input file...'
task 'run-perf', 'run small performance test to check whether everything is ok', (options) ->
    printOutput = (error, stdout, stderr) ->
        print 'ERROR:' + error if error
        print stdout if stdout
        print 'STDERR:' + stderr if stderr
    exec 'node lib/insertWikipediaToSphinx.js ' + options['inputfile'],
         ((error, stdout, stderr) -> 
            printOutput(error, stdout, stderr)
            exec 'node lib/cleanRTWikiDB.js',
                (error, stdout, stderr) -> 
                    printOutput(error, stdout, stderr)
                    exec 'cat insertionlog.csv', printOutput
                )
            
        
            
    
    