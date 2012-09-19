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
task 'clean-sphinx', 'clean sphinx rtwiki index', (options) ->
    cleanTask = spawn('node', ['lib/cleanRTWikiDB.js'])
    cleanTask.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    cleanTask.stdout.on 'data', (data) ->
      print data.toString()

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
task 'run-perf', 'run performance test for searching and inserting', (options) ->
    insertTask = spawn('node', ['lib/startInserting.js', options['inputfile']])
    insertTask.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    insertTask.stdout.on 'data', (data) ->
      print data.toString()
    process.stdin.pipe(insertTask.stdin)
    searchTask = spawn('node', ['lib/performanceTestSearcher.js', options['inputfile']])
    searchTask.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    searchTask.stdout.on 'data', (data) ->
      print data.toString()
    process.stdin.pipe(searchTask.stdin)
            
    
    