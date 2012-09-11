fs = require 'fs'

{print} = require 'sys'
{spawn} = require 'child_process'

build = (callback) ->
  coffee = spawn 'coffee', ['-c', '-o', 'lib', 'src']
  coffee.stderr.on 'data', (data) ->
    process.stderr.write data.toString()
  coffee.stdout.on 'data', (data) ->
    print data.toString()
  coffee.on 'exit', (code) ->
    callback?() if code is 0

task 'build', 'Build lib/ from src/', ->
  build()

task 'compile-on-change', 'Compile src/ and test/ to lib and lib/test on changes', ->
    invoke 'compile-source-on-change'
    invoke 'compile-tests-on-change'

task 'compile-source-on-change', 'Watch src/ for changes and compile to lib/', ->
    coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib', 'src']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()


task 'compile-tests-on-change', 'Watch test/ for changes and compile to lib/test', ->
    coffee = spawn 'coffee', ['-w', '-c', '-o', 'lib/test', 'test']
    coffee.stderr.on 'data', (data) ->
      process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
      print data.toString()
